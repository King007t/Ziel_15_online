public class SpielManagerClient extends SpielManager {

  Spieler onlineSpieler;

  // --- Reset-Methode ---

  public void reset() {
    spieler = 0;
    mode = 0;
    programmstart = 60 * 3;
    werten = 0;
    mconsole = "fetching...";
    dconsole = "fetching...";
    console.clear();
    akSpieler.clear();
  }

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
          if (packet[2] == 1)
            jointext = "Die Lobby ist voll";
          else
            jointext = "Das Spiel läuft bereits";
          j = 0;
          client.stop();
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
        j = 0;
        return;
      }
      if (myId == int(packet[1])) {
        client.stop();
        reset();
        programmstart = 0;
      } else if (myId > int(packet[1]))
        myId--;
      break;
      case(3): //syncronisation akSpieler at start
      String name = "";
      for (int i = 2; i < packet.length; i++) {
        if (packet[i] == -1)
          break;
        name += char(packet[i]);
      }
      Spieler s = packet[1] == myId ? new OnlineSpielerSender(name) : new OnlineSpielerReciever(name, packet[1]);
      println("packet 1: "+ packet[1] + "myId: " + myId + "constructor: " + s);
      akSpieler.add(s);
      sendPacket(3, myId);
      break;
      case(4): //sync midgame
      if (packet[1] == 1) {
        aktWurfBuffer = packet[2];
        sendPacket(3, myId);
      }
      if (packet[1] == 2) {
        if (packet[2] != myId)
          valBuffer = packet[3];
        sendPacket(3, myId);
      }
      break;
      case(5): //restart or exit
      if (packet[1] == 1) {
        reset();
      }
      if (packet[1] == 2) {
        surface.setTitle("Ziel_15: Spiel wird beendet");
        exit();
      }
      break;
      case(6): // chat
      String message = "";
      for (int i = 1; i < packet.length; i++) {
        if (packet[i] == -1)
          break;
        message += char(packet[i]);
      }
      meldeChat(message);
      break;
    }
  }

  void disconnect() {
    sendPacket(2, myId);
  }

  // --- Chat-Methoden ---

  void sendChat(String message) {
    byte[] messagePacket = new byte[23];
    messagePacket[0] = 6;
    String name = message;
    char[] nameChars = name.toCharArray();
    for (int i = 1; i < messagePacket.length; i++) {
      if (i-1 >= nameChars.length) {
        messagePacket[i] = -1;
        break;
      }
      messagePacket[i] = byte(nameChars[i-1]);
    }
    client.write(messagePacket);
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
        valBuffer = 0;
      }
    }
    refresh();
  }

  // --- Logik-Methoden ---

  protected void init() {
    uim.buttons.get(1).caninteract = false;
    programmstart = 60 * 3 + 1;
    surface.setTitle("Ziel_15: Online_Match");
    mode = 3;
  }

  public void gewonnen() {
    if (mode == 3) {
      mode++;
      Spieler gewinner = getWinner();
      if (gewinner == null) {
        meldeDaten("Unentschieden");
      } else {
        meldeDaten("Winner:\n" + gewinner.getName());
      }
      meldeDialog("Noch ein mal? Warte auf " + akSpieler.get(0).name);
    }
  }
}
