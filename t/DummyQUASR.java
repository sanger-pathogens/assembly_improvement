import java.io.*;

public class DummyQUASR {

	public static void main(String[] args) {

		String currentDirectory = System.getProperty("user.dir");
	
		// create File objects
		File resultsFile_forward = new File(currentDirectory.concat("/primer_removed.qc.f.fq.gz"));
		File resultsFile_reverse = new File(currentDirectory.concat("/primer_removed.qc.r.fq.gz"));
	
		try {
			resultsFile_forward.createNewFile();
			resultsFile_reverse.createNewFile();
		} catch (IOException ioe) {
			System.out.println("Error while creating dummy QUASR results files in Java" + ioe);
		}

	}
}


