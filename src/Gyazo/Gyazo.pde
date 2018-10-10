// package gyazo;

/**
 * @author progfay
 */

import java.io.ByteArrayOutputStream;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.util.Base64;
import http.requests.PostRequest;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.awt.datatransfer.Clipboard;
import java.awt.Toolkit;
import java.awt.datatransfer.StringSelection;
import java.awt.Desktop;
import java.net.URI;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;


/**
 * Application client id.
 * The client id function does not touch the data of users, you can safely use this in public code.
 */
private final String CLIENT_ID = "fbabf8fca3536ae735c4a42eaa75065945f22d20b80d5278ad93feb04f69babb";


/**
 * Capture and upload the window then open in default browser.
 */
public String capture () {
  return this.upload(get());
}

/**
 * Capture and upload the window then open in default browser.
 * @param x x-coordinate of the start pixel
 * @param y y-coordinate of the start pixel
 * @param w width of pixel rectangle to get
 * @param h height of pixel rectangle to get
 */
public String capture (int x, int y, int w, int h) {
  return this.upload(get(x, y, w, h));
}


/**
 * Upload image for Gyazo.
 * @param img image
 */
public String upload (PImage img) {
  ByteArrayOutputStream out = new ByteArrayOutputStream();
  try {
    ImageIO.write((BufferedImage)img.getNative(), "PNG", out);
  }
  catch (IOException e) {
    e.printStackTrace();
    return "";
  }

  String image_url = "data:image/png;base64," + Base64.getEncoder().encodeToString(out.toByteArray());

  PostRequest post = new PostRequest("https://upload.gyazo.com/api/upload/easy_auth");
  post.addData("client_id", CLIENT_ID);
  post.addData("image_url", image_url);
  post.addData("referer_url", "https://processing.org");
  post.send();

  Pattern pattern = Pattern.compile("https://gyazo\\.com/api/upload/[a-z0-9]*");
  Matcher matcher = pattern.matcher(post.getContent());
  if (!matcher.find()) {
    System.err.println("HTTP Response Exception: ");
    return "";
  }
  String url = matcher.group(0);

  StringSelection selection = new StringSelection(url);
  Toolkit.getDefaultToolkit()
    .getSystemClipboard()
    .setContents(selection, selection);

  try {
    Desktop.getDesktop().browse(new URI(url));
  }
  catch (URISyntaxException e) {
    e.printStackTrace();
    return "";
  }
  catch(IOException e) {
    e.printStackTrace();
    return "";
  }

  return url;
}
