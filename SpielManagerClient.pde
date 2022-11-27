public class SpielManagerClient extends SpielManager {

  int myId = -1;
  Spieler onlineSpieler;

  // --- Konstruktoren ---

  public SpielManagerClient(String ip) {
    super();
    client = new Client(Ziel_15.this, ip, 5204);
    byte[] handShakePacket = new byte[20];
    handShakePacket[0] = 0;
    String name = uim.buttons.get(6).text;
    char[] nameChars = name.toCharArray();

    for (int i = 1; i < handShakePacket.length; i++) {

      if (i-1 >= nameChars.length) {
        handShakePacket[i] = -1;
        break;
      }

      handShakePacket[i] = byte(nameChars[i-1]);
    }

    client.write(handShakePacket);
  }

  // --- Client-Methode ---

  public void sendPacket(int... packet) {
    byte[] toSend = new byte[packet.length];
    for (int i = 0; i < packet.length; i++) {
      toSend[i] = byte(packet[i]);
    }
    client.write(toSend);
  }

  public void clientRefresh() {
    if (client.available() > 0) {
      byte[] byteBuffer = client.readBytes();
      handlePacket(byteBuffer);
    }
  }

  public void handlePacket(byte[] packet) {
    switch(packet[0]) {
      case(0):
        if (myId == -1) {
          myId = (int)packet[1];
          println("Angemeldet als client: " + myId);
        }
        break;
      case(1):
        init();
        break;
    }
  }

  // --- Spielablauf-Methode ---

  protected void init() {
    surface.setTitle("Ziel_15: Online_Match");
    meldeDialog("Server sagt start");
  }


  public void spielAblauf() {
    //clientRefresh(client);
    if (programmstart == 60 * 3) {
      init();
      programmstart++;
    } else {
      if (keyPressed) {
        if (mode == 0) {
          setupSpieleranzahl();
        } else if (j < Integer.valueOf(input) && mode == 1) {
          setupName();
        } else if (mode == 2) {
          setupZn();
        }
      }
      if (mode >= 3) {
        if (akSpieler.size() > 0 && akSpieler.get(akSpieler.size() - 1).getAnzWuerfe() >= 10) {
          surface.setTitle("Ziel_15: Erneut spielen?");
          gewonnen();
        } else {
          surface.setTitle("Ziel_15: Aktives Spiel");
          if (keyPressed && akSpieler.get(spieler).getGZN()) {
            setZn();
          }
          akSpieler.get(spieler).spieleRunde();
        }
      }
      refresh();
    }
  }
}
