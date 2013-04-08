import java.io.*;

public class DummyQUASR {

	public static void main(String[] args) {

		String currentDirectory = System.getProperty("user.dir");
	
		// create File object
		File resultsFile = new File(currentDirectory.concat("/primer_removed.qc.fastq.gz"));
	
		try {
			resultsFile.createNewFile();
		} catch (IOException ioe) {
			System.out.println("Error while creating dummy QUASR results file in Java" + ioe);
		}

	}
}


