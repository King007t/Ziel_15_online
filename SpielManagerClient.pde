public class SpielManagerClient extends SpielManager {

  public int myId = -1;
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
    println(packet);
    switch(packet[0]) {
      case(0): //handshake
      if (myId == -1) {
        myId = (int)packet[1];
        if (myId == -1) {
          jointext = "Das Spiel läuft bereits";
          manager.j = 0;
          return;
        }
      }
      break;
      case(1): //gamestart
      init();
      break;
      case(2): //disconnect
      println((int)packet[1]);
      if ((int) packet[1] == -1) {
        jointext = "Verbindung zum Host verloren";
        manager.j = 0;
        return;
      }
      if (myId == int(packet[1])) {
        client.stop();
        reset();
        programmstart = 0;
      }
      else if (myId > int(packet[1]))
        myId--;
      break;
      case(3): //syncronisation
      if ((int)packet[2] == myId)
        
      break;
    }
  }

  void disconnect() {
    sendPacket(2, myId);
  }
  // --- Spielablauf-Methode ---

  public void spielAblauf() {
    if (mode >= 3) {
      if (akSpieler.size() > 0 && akSpieler.get(akSpieler.size() - 1).getAnzWuerfe() >= 10) {
        surface.setTitle("Ziel_15: Erneut spielen?");
        gewonnen();
      } else {
        surface.setTitle("Ziel_15: aktives_Online_Match");
        akSpieler.get(spieler).spieleRunde();
      }
    }
    refresh();
  }

  // --- Logik-Methoden ---

  protected void init() {
    uim.buttons.get(1).caninteract = false;
    programmstart = 60 * 3 + 1;
    meldeDialog("Angemeldet als Spieler: " + (myId + 2));
    meldeDialog("Dein Name: " + uim.buttons.get(6).text);
    akSpieler.add(new OnlineSpielerSender(uim.buttons.get(6).text));
    meldeDialog("------------------------------------");
    surface.setTitle("Ziel_15: Online_Match");
    mode = 3;
  }
}
