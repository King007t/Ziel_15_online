public class SpielManagerHost extends SpielManager {

  public ArrayList<Client> clientMap = new ArrayList<>();
  public ArrayList<String> names = new ArrayList<>();
  // --- Konstruktoren ---

  public SpielManagerHost() {
    super();
    server = new Server(Ziel_15.this, 5204);
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
    
    if(!clientMap.contains(sender) && packet[0] != 0)
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
        sendPacket(2,packet[1]);
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


  // --- Logik-Methoden ---

  protected void init() {

    sendPacket(1);

    surface.setTitle("Ziel_15: Online_Match");
    akSpieler.add(new Spieler(uim.buttons.get(6).text));
    akSpieler.add(new Spieler(onlineName));
    meldeDialog("ONLINE SPIEL START:");
    meldeDialog("------------------------------------");
    meldeDialog("Spieler " + (spieler + 1) + ": " + akSpieler.get(spieler).name + " ist am Zug");
    mode = 3;
  }
}
