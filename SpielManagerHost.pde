public class SpielManagerHost extends SpielManager {

  // --- Konstruktoren ---

  public SpielManagerHost() {
    super();
    server = new Server(Ziel_15.this, 5204);
  }

  // --- Reset-Methode ---

  public void reset() {
    spieler = 0;
    mode = 3;
    programmstart = 60 * 3;
    werten = 0;
    mconsole = "fetching...";
    dconsole = "fetching...";
    console.clear();
    akSpieler.clear();
  }

  // --- Server-Methode ---

  public void serverRefresh() {
    if (server.available() != null) {
      byte[] byteBuffer =  new byte[23];
      int byteCount = server.available().readBytes(byteBuffer);
      if (byteCount > 0)
        handlePacket(server.available(), byteBuffer);
    }
  }

  public void handlePacket(Client sender, byte[] packet) {
    if (!clientMap.contains(sender) && packet[0] != 0)
      return;
    println(packet);
    switch(packet[0]) {
      case(0): //handshake
      if (programmstart == 60 * 3 + 1) { //spiel hat bereits gestartet
        sendPacket(0, -1, 0);
        return;
      }
      if (clientMap.size() >= 3) { //lobby voll
        sendPacket(0, -1, 1);
        return;
      }
      String name = "";
      for (int i = 1; i < packet.length; i++) {
        if (packet[i] == -1)
          break;
        name += char(packet[i]);
      }
      clientMap.add(sender);
      names.add(name);
      byte[] newPacket = new byte[] {0, byte(clientMap.size() - 1)};
      server.write(newPacket);
      isConnected = true;
      break;
      case(2): // disconnect
      clientMap.remove(int(packet[1]));
      names.remove(int(packet[1]));
      if (clientMap.size() == 0)
        isConnected = false;
      sendPacket(2, packet[1]);
      break;
      case(3): // check if all clients succesfully recieved packet
      if (!list.hasValue((int) packet[1]))
        list.append((int) packet[1]);
      break;
      case(4): // sync midgame
      valBuffer = packet[2];
      sendPacket(4, 2, packet[1], packet[2]);
      break;
      case(6): // chat
      String message = "";
      for (int i = 1; i < packet.length; i++) {
        if (packet[i] == -1)
          break;
        message += char(packet[i]);
      }
      sendChat(message);
      break;
    }
  }

  public void sendPacket(int... packet) {
    byte[] toSend = new byte[packet.length];
    for (int i = 0; i < packet.length; i++) {
      toSend[i] = byte(packet[i]);
    }
    server.write(toSend);
  }

  void disconnect() {
    sendPacket(2, -1);
    server.stop();
    isConnected = false;
  }

  // --- Chat-Methoden ---

  void sendChat(String message) {
    meldeChat(message);
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
    server.write(messagePacket);
  }

  // --- Spielablauf-Methode ---

  public void spielAblauf() {
    if (programmstart == 60 * 3) {
      init();
      programmstart++;
    } else if (mode >= 3) {
      if (akSpieler.size() > 0 && akSpieler.get(akSpieler.size() - 1).getAnzWuerfe() >= 10) {
        surface.setTitle("Ziel_15: Erneut spielen?");
        gewonnen();
      } else {
        surface.setTitle("Ziel_15: aktives_Online_Match");
        akSpieler.get(spieler).spieleRunde();
        valBuffer = 0;
        //aktWurfBuffer = 0;
      }
    }
    refresh();
  }

  // --- Logik-Methoden ---

  protected void init() {
    delay(1000);
    surface.setTitle("Ziel_15: pre_Online_Match");
    akSpieler.add(new OnlineSpielerHost(uim.buttons.get(6).text));
    String name = uim.buttons.get(6).text;
    char[] nameChars = name.toCharArray();
    byte[] addPacket = new byte[13];
    addPacket[0] = 3;
    addPacket[1] = -1;
    for (int i = 2; i < addPacket.length; i++) {
      if (i-2>= nameChars.length) {
        addPacket[i] = -1;
        break;
      }
      addPacket[i] = byte(nameChars[i-2]);
    }
    server.write(addPacket);
    delay(100);
    boolean accepted = false;
    while (!accepted) {
      println("while");
      serverRefresh();
      if (list.size() > 0) {
        accepted = true;
        list.clear();
      }
      delay(10);
    }
    for (int i = 0; i < clientMap.size(); i++) {
      akSpieler.add(new OnlineSpielerReciever(names.get(i), i));
      String name2 = names.get(i);
      char[] nameChars2 = name2.toCharArray();
      byte[] addPacket2 = new byte[13];
      addPacket2[0] = 3;
      addPacket2[1] = (byte) i;
      for (int j = 2; j < addPacket2.length; j++) {
        if (j-2 >= nameChars2.length ) {
          addPacket2[j] = -1;
          break;
        }

        addPacket2[j] = byte(nameChars2[j-2]);
      }
      server.write(addPacket2);
      delay(100);
      boolean accepted2 = false;
      while (!accepted2) {
        println("while2");
        serverRefresh();
        if (list.size() > 0) {
          accepted2 = true;
          list.clear();
        }
        delay(10);
      }
    }
    sendPacket(1);
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
        //meldeDialog(gewinner.gibDaten());
      }
      meldeDialog("Noch ein mal? JA oder Nein");
    }
    uim.buttons.get(7).caninteract = true;
    uim.buttons.get(8).caninteract = true;
    uim.buttons.get(8).text = "Ja";
    int dialog = werten;
    if (dialog == 1) {
      uim.buttons.get(8).text = "Werten";
      uim.buttons.get(7).caninteract = false;
      uim.buttons.get(8).caninteract = false;
      sendPacket(5, 1);
      delay(100);
      reset();
    }
    if (dialog == 2) {
      sendPacket(5, 2);
      surface.setTitle("Ziel_15: Spiel wird beendet");
      exit();
    }
  }
}
