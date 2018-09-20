import java.awt.Desktop;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

/**
 * @author progfay
 */
public class Gyazo {
  /**
   * User's access token
   */
  private String accessToken = null;

  /**
   * Instantiates a new Gyazo object.
   * @param _accessToken User's access token
   */
  public Gyazo (String _accessToken) {
    this.accessToken = new String(_accessToken);
  }

  /**
   * Capture and upload the window then print URL.
   */
  void capture () {
    this.upload(get(), false);
  }

  /**
   * Capture and upload the window.
   * @param browse true for browsing, false for printing URL
   */
  void capture (boolean browse) {
    this.upload(get(), browse);
  }

  /**
   * Capture and upload the window then print URL.
   * @param x x-coordinate of the start pixel
   * @param y y-coordinate of the start pixel
   * @param w width of pixel rectangle to get
   * @param h height of pixel rectangle to get
   */
  void capture (int x, int y, int w, int h) {
    this.upload(get(x, y, w, h), false);
  }

  /**
   * Capture and upload the window.
   * @param x x-coordinate of the start pixel
   * @param y y-coordinate of the start pixel
   * @param w width of pixel rectangle to get
   * @param h height of pixel rectangle to get
   * @param browse true for browsing, false for printing URL
   */
  void capture (int x, int y, int w, int h, boolean browse) {
    PImage img = get(x, y, w, h);
    this.upload(img, browse);
  }

  /**
   * Upload image then print URL.
   * @param img image
   */
  void upload (PImage img) {
    this.upload(img, false);
  }

  /**
   * Upload image.
   * @param img image
   * @param browse true for browsing, false for printing URL
   */
  void upload (PImage img, boolean browse) {
    StringList stdout = new StringList();
    StringList stderr = new StringList();

    String imagePath = ".gyazo/" + millis() + ".png";
    img.save(imagePath);

    shell(stdout, stderr, 
      "curl", 
      "-i", "https://upload.gyazo.com/api/upload", 
      "-F", "access_token=" + this.accessToken, 
      "-F", "imagedata=@" + sketchPath() + "/" + imagePath);

    JSONObject json = parseJSONObject(stdout.get(stdout.size()-1));
    String     url  = json.getString("permalink_url");

    if (browse) {
      try {
        Desktop.getDesktop().browse(new URI(url));
      }
      catch (URISyntaxException e) {
        e.printStackTrace();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    } else {
      println(url);
    }
  }
}
