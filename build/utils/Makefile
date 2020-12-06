PROGRAM=SSB64ImageFileAppender
PROGRAM2=SSB64FileAppender

# compile and create executable
all:
	javac -cp . $(PROGRAM).java
	jar cmf $(PROGRAM).mf $(PROGRAM).jar $(PROGRAM).class $(PROGRAM).java
	javac -cp . $(PROGRAM2).java
	jar cmf $(PROGRAM2).mf $(PROGRAM2).jar $(PROGRAM2).class $(PROGRAM2).java

# clean output
clean:
	rm -rf *.jar
	rm -rf *.class