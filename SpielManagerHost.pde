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
  }

  // --- Server-Methode ---

  public void serverRefresh() {
    if (server.available() != null) {
      byte[] byteBuffer = new byte[20];
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
      if (programmstart == 60 * 3 + 1) {
        sendPacket(0, -1);
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
      boolean listcontains = false;
      for (int i : list) {
        if (list.get(i) == (int) packet[1]) {
          listcontains = true;
          break;
        }
      }
      if (!listcontains)
        list.append((int) packet[1]);
      break;
      case(4): // sync midgame
      valBuffer = packet[2];
      sendPacket(4, 2, packet[1] , packet[2]);
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
    boolean accepted = false;
    while (!accepted) {
      serverRefresh();
      if (list.size() == clientMap.size()) {
        accepted = true;
        list.clear();
      }
    }
    for (Client client : clientMap) {
      akSpieler.add(new OnlineSpielerReciever(names.get(clientMap.indexOf(client)), clientMap.indexOf(client)));
      String name2 = names.get(clientMap.indexOf(client));
      char[] nameChars2 = name2.toCharArray();
      byte[] addPacket2 = new byte[13];
      addPacket2[0] = 3;
      addPacket2[1] = (byte) clientMap.indexOf(client);

      for (int i = 2; i < addPacket2.length; i++) {
        if (i-2 >= nameChars2.length ) {
          addPacket2[i] = -1;
          break;
        }

        addPacket2[i] = byte(nameChars2[i-2]);
      }

      server.write(addPacket2);
      boolean accepted2 = false;
      while (!accepted2) {
        serverRefresh();
        if (list.size() == clientMap.size()) {
          accepted2 = true;
          list.clear();
        }
      }
    }
    sendPacket(1);
    meldeDialog("Angemeldet als Spieler: 1");
    meldeDialog("Dein Name: " + uim.buttons.get(6).text);
    meldeDialog("------------------------------------");
    meldeDialog("ONLINE SPIEL START:");
    meldeDialog("------------------------------------");
    meldeDialog("Spieler " + (spieler + 1) + ": " + akSpieler.get(spieler).name + " ist am Zug");
    mode = 3;
  }
  
  public void gewonnen() {
    if (mode == 3) {
      mode++;
      meldeDialog("------------------------------------");
      meldeDialog("SPIEL ENDE:");
      meldeDialog("------------------------------------");
      Spieler gewinner = getWinner();
      if (gewinner == null) {
        meldeDialog("Unentschieden");
      } else {
        meldeDialog(gewinner.getName() + " hat gewonnen.");
        meldeDialog(gewinner.gibDaten());
      }
      meldeDialog("------------------------------------");
      meldeDialog("Noch ein mal? JA(j) oder Nein(n)");
    }
    int dialog = dialog();
    if (dialog == 1) {
      sendPacket(5, 1);
      reset();
      init();
    }
    if (dialog == 2) {
      sendPacket(5, 2);
      surface.setTitle("Ziel_15: Spiel wird beendet");
      exit();
    }
  }
}
