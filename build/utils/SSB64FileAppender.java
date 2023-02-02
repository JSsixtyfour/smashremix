import java.io.*;
import java.util.Arrays;
import java.nio.file.*;

public class SSB64FileAppender {

	public static void main(String[] args) {
		SSB64FileAppender appender = new SSB64FileAppender();
		if (args.length != 3 && args.length != 5) {
			System.out.println("usage: java -jar SSB64FileAppender.jar <path/to/file_containing_new_data> <offset_in_original_file> <internal_file_table_offset> [<path/to/file_to_append> <internal_file_table_offset>]");
			System.exit(0);
		}
		if (args.length == 3) {
			appender.run(args[0], Integer.decode(args[1]), Integer.decode(args[2]), null, null);
		} else {
			appender.run(args[0], Integer.decode(args[1]), Integer.decode(args[2]), args[3], Integer.decode(args[4]));
		}
	}

	public void run(String filenameNewData, Integer originalOffset, Integer internalFileTableOffset, String filenameTarget, Integer internalFileTableOffsetTarget) {
		byte[] newData = new byte[0];
		int newDataLength = 0;
		byte[] existingData = new byte[0];
		int existingDataLength = 0;
		byte outArray[] = new byte[0];
		int offset = internalFileTableOffset;

		// this correction value will be applied to all pointers we find
		// initially it is the originalOffset, but if a target file is specified we must account for the internal file table offset of that file
		int correction = 0 - originalOffset;

		try {
			// read data of file to add
			newData = Files.readAllBytes(Paths.get(filenameNewData));
			newDataLength = newData.length;

			// read data of file to add to
			if (filenameTarget != null) {
				existingData = Files.readAllBytes(Paths.get(filenameTarget));
				existingDataLength = existingData.length;

				// correction value needs to be increased by the size of the file
				correction += existingDataLength;

				offset += existingDataLength;
			}
		} catch (IOException e) {
			// close when file is not present
			System.out.println("File not found!");
			System.exit(0);

		} catch (Exception e) {
			// generic error catch
			System.out.println("Unknown error occured!");
			System.exit(0);
		}

		// combine the files
		outArray = new byte[existingDataLength + newDataLength];
		System.arraycopy(existingData, 0, outArray, 0, existingDataLength);
		System.arraycopy(newData, 0, outArray, existingDataLength, newDataLength);

		//System.out.println("correction: " + String.format("0x%08X", correction) + " (" + correction + ")");

		// now loop through file's pointers, updating as we go
		// first, update the final pointer in the target file to the first pointer address in the added file
		if (filenameTarget != null) {
			if (internalFileTableOffsetTarget > 0) {
				int offsetTarget = internalFileTableOffsetTarget;

				while (offsetTarget < outArray.length) {
					int[] pointers = getPointers(outArray, offsetTarget);
					// System.out.println("next: " + String.format("0x%08X", pointers[0]) + ", data: " + String.format("0x%08X", pointers[1]));

					if (pointers[0] == 0xFFFFFFFC || pointers[0] == 0x0003FFFC) {
						outArray[offsetTarget] = (byte) ((offset / 4) >> 8);
						outArray[offsetTarget + 0x01] = (byte) (offset / 4);
						break;
					}

					offsetTarget = pointers[0];
				}
			}
		}
		// next, update pointers in the new added data
		while (offset < outArray.length && offset >= 0) {
			int[] pointers = getPointers(outArray, offset);
			// System.out.println("next: " + String.format("0x%08X", pointers[0]) + ", data: " + String.format("0x%08X", pointers[1]));
			// System.out.println("next: " + String.format("0x%08X", pointers[0] + correction) + ", data: " + String.format("0x%08X", pointers[1] + correction));

			if (!(pointers[0] == 0xFFFFFFFC || pointers[0] == 0x0003FFFC) && ((pointers[0] + correction) < outArray.length) && ((pointers[0] + correction) >= 0)) {
				outArray[offset] = (byte) (((pointers[0] + correction) / 4) >> 8);
				outArray[offset + 0x01] = (byte) ((pointers[0] + correction) / 4);
			} else {
				// if this is the last pointer, set to 0xFFFF
				outArray[offset] = (byte) 0xFF;
				outArray[offset + 0x01] = (byte) 0xFF;
			}
			outArray[offset + 0x02] = (byte) (((pointers[1] + correction) / 4) >> 8);
			outArray[offset + 0x03] = (byte) ((pointers[1] + correction) / 4);

			if ((pointers[1] - originalOffset) < 0) {
				System.out.println("Warning! Data pointer at " + String.format("0x%08X", offset) + " references external offset (before start of added file):" + String.format("0x%08X", pointers[1] + correction));
			} else if ((pointers[1] - originalOffset) >= newDataLength) {
				System.out.println("Warning! Data pointer at " + String.format("0x%08X", offset) + " references external offset (after end of added file):" + String.format("0x%08X", pointers[1] + correction));
			}

			if (pointers[0] == 0xFFFFFFFC || pointers[0] == 0x0003FFFC) {
				break;
			}

			offset = pointers[0] + correction;
		}

		// output the file
		try (FileOutputStream fos = new FileOutputStream("./output.bin")) {
			fos.write(outArray);
		} catch (Exception e) {
			System.out.println("Unknown error occured!");
			System.exit(0);
		}
	}

	public int[] getPointers(byte[] dataArray, int offset) {
		// System.out.println("offset: " + String.format("0x%08X", offset));
		// System.out.println("next: " + String.format("0x%02X", dataArray[offset]) + " " + String.format("0x%02X", dataArray[offset + 0x01]) + ", data: " + String.format("0x%08X", dataArray[offset + 0x02]) + " " + String.format("0x%08X", dataArray[offset + 0x03]));
		// System.out.println("nextPointer upper: " + String.format("0x%08X", (dataArray[offset] << 8) & 0xFF00));

		int nextPointer = (int) ((((dataArray[offset] << 8) & 0xFF00) | (dataArray[offset + 0x01] & 0xFF)) * 4);
		int dataPointer = (int) ((((dataArray[offset + 0x02] << 8) & 0xFF00) | (dataArray[offset + 0x03] & 0xFF)) * 4);

		// System.out.println("nextPointer: " + String.format("0x%08X", nextPointer));
		// System.out.println("dataPointer: " + String.format("0x%08X", dataPointer));

		int[] returnVal = {nextPointer, dataPointer};

		return returnVal;
	}

}
