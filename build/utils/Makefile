PROGRAM=SSB64ImageFileAppender

# compile and create executable
all:
	javac -cp . $(PROGRAM).java
	jar cmf $(PROGRAM).mf $(PROGRAM).jar $(PROGRAM).class $(PROGRAM).java

# clean output
clean:
	rm -rf *.jar
	rm -rf *.class