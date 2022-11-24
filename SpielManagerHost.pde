public class SpielManagerHost extends SpielManager {

  private ArrayList<Client> clients = new ArrayList();

  // --- Konstruktoren ---

  public SpielManagerHost() {
    super();
    server = new Server(Ziel_15.this, 5204);
  }

  // --- Server-Methode ---

  public void serverRefresh() {
    Client currentClient = server.available();
    if (currentClient == null)
      return;

    println("connection established");
    byte[] byteBuffer = new byte[10];
    int byteCount = currentClient.readBytes(byteBuffer);
    if (byteCount > 0)
      handlePacket(byteBuffer);
  }

  public void handlePacket(byte[] packet) {
    if (packet[0] == 0) {
      isConnected = true;
    }
  }

  public void serverEvent(Server myServer, Client newClient) {
    if (myServer != server)
      return;
    clients.add(newClient);
    byte[] packet = new byte[] {0, byte(clients.size() - 1)};
    server.write(packet);
  }

  // --- Spielablauf-Methode ---


  // --- Logik-Methoden ---

  protected void init() {
    surface.setTitle("Ziel_15: Online_Match");
    akSpieler.add(new Spieler(uim.buttons.get(6).text));
    akSpieler.add(new Spieler(onlineName));
    meldeDialog("ONLINE SPIEL START:");
    meldeDialog("------------------------------------");
    meldeDialog("Spieler " + (spieler + 1) + ": " + akSpieler.get(spieler).name + " ist am Zug");
    mode = 3;
  }
}
