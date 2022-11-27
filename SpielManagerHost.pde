public class SpielManagerHost extends SpielManager {

  public HashMap<String, Client> clientMap = new HashMap<>();

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
    if (packet[0] == 0) {
      //isConnected = true;
       String name = "";
       for(int i = 1; i < packet.length; i++){
           if(packet[i] == -1)
             break;
             
           name += char(packet[i]);
       }
       clientMap.put(name, sender);
       byte[] newPacket = new byte[] {0, byte(clientMap.size() - 1)};
       server.write(newPacket);
       isConnected = true;
    }
  }
  
  public void sendPacket(int... packet){
    byte[] toSend = new byte[packet.length];
    for(int i = 0; i < packet.length; i++){
      toSend[i] = byte(packet[i]);
    }
     server.write(toSend);
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
