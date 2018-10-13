// package gyazo;

/**
 * @author progfay
 */

import java.io.ByteArrayOutputStream;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.util.Base64;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.InputStreamReader;
import java.io.DataOutputStream;
import java.util.UUID;
import java.util.HashMap;
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
public void capture () {
  this.upload(get());
}

/**
 * Capture and upload the window then open in default browser.
 * @param x x-coordinate of the start pixel
 * @param y y-coordinate of the start pixel
 * @param w width of pixel rectangle to get
 * @param h height of pixel rectangle to get
 */
public void capture (int x, int y, int w, int h) {
  this.upload(get(x, y, w, h));
}


/**
 * Upload image for Gyazo.
 * @param img image
 */
public void upload (PImage img) {
  ByteArrayOutputStream out = new ByteArrayOutputStream();
  try {
    ImageIO.write((BufferedImage)img.getNative(), "PNG", out);
  } 
  catch (IOException e) {
    e.printStackTrace();
    return;
  }

  String image_url = "data:image/png;base64," + Base64.getEncoder().encodeToString(out.toByteArray());

  //PostRequest post = new PostRequest("https://upload.gyazo.com/api/upload/easy_auth");

  HashMap<String, String> param = new HashMap<String, String>();
  param.put("client_id", CLIENT_ID);
  param.put("image_url", image_url);
  param.put("referer_url", "https://processing.org");
  String response = postRequest("https://upload.gyazo.com/api/upload/easy_auth", param);


  Pattern pattern = Pattern.compile("https://gyazo\\.com/api/upload/[a-z0-9]*");
  //Matcher matcher = pattern.matcher(post.getContent());
  Matcher matcher = pattern.matcher(response);
  if (!matcher.find()) {
    System.err.println("HTTP Response Exception: ");
    return;
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
  }
  catch(IOException e) {
    e.printStackTrace();
  }
}


private String postRequest(String api, HashMap<String, String> data) {
  final String twoHyphens = "--";
  final String boundary =  "*****"+ UUID.randomUUID().toString()+"*****";
  final String lineEnd = "\r\n";

  try {
    URL url = new URL(api);

    HttpURLConnection con = (HttpURLConnection)url.openConnection();
    con.setRequestMethod("POST");
    con.setInstanceFollowRedirects(false);
    con.setRequestProperty("Connection", "Keep-Alive");
    con.setRequestProperty("Content-Type", "multipart/form-data; boundary="+boundary);
    con.setDoOutput(true);
    con.setDoInput(true);
    con.setUseCaches(false);

    DataOutputStream dos = new DataOutputStream(con.getOutputStream());

    for (HashMap.Entry<String, String> entry : data.entrySet()) {
      Object value = entry.getValue();
      dos.writeBytes(twoHyphens + boundary + lineEnd);
      dos.writeBytes("Content-Disposition: form-data; name=\""+entry.getKey()+"\""+lineEnd);
      dos.writeBytes("Content-Type: text/plain"+lineEnd);
      dos.writeBytes(lineEnd);
      dos.writeBytes((String)value);
      dos.writeBytes(lineEnd);
    }

    dos.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);
    dos.close();
    con.connect();

    StringBuffer result = new StringBuffer();
    final int status = con.getResponseCode();
    if (status == HttpURLConnection.HTTP_OK) {
      final InputStream in = con.getInputStream();
      final InputStreamReader inReader = new InputStreamReader(in, "UTF-8");
      final BufferedReader bufReader = new BufferedReader(inReader);
      String line = null;
      while ((line = bufReader.readLine()) != null) {
        result.append(line);
      }
      bufReader.close();
      inReader.close();
      in.close();

      return result.toString();
    }
    return "";
  }
  catch(Exception e) {
    e.printStackTrace();
    return "";
  }
}
