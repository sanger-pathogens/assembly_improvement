import java.io.*;

public class DummyTrimmomatic {

	public static void main(String[] args) {

		String currentDirectory = System.getProperty("user.dir");
	
		// create File objects
		File resultsFile_paired_forward = new File(currentDirectory.concat("/trimmed.paired_1.fastq"));
		File resultsFile_paired_reverse = new File(currentDirectory.concat("/trimmed.paired_2.fastq"));
        File resultsFile_unpaired_forward = new File(currentDirectory.concat("/trimmed.unpaired_1.fastq"));
        File resultsFile_unpaired_reverse = new File(currentDirectory.concat("/trimmed.unpaired_2.fastq"));
	
		try {
            resultsFile_paired_forward.createNewFile();
            resultsFile_paired_reverse.createNewFile();
            resultsFile_unpaired_forward.createNewFile();
            resultsFile_unpaired_reverse.createNewFile();
		} catch (IOException ioe) {
			System.out.println("Error while creating dummy Trimmomatic results files in Java" + ioe);
		}

	}
}


