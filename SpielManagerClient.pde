public class SpielManagerClient extends SpielManager {
  
  int myId = -1;
  Spieler onlineSpieler;

  // --- Konstruktoren ---

  public SpielManagerClient(String ip) {
    super();
    client = new Client(Ziel_15.this, ip, 5204);
  }
  
  // --- Client-Methode ---
  
   public void clientEvent(Client myClient) {
     byte[] byteBuffer = new byte[10];
     int byteCount = myClient.readBytes(byteBuffer);
     if (byteCount == 0)
       return;
       
     println("connected");
     handlePacket(byteBuffer);
   }
   
   public void handlePacket(byte[] packet){
     if(packet[0] == 0) {
       // handshake
       if (myId == -1) {
         myId = packet[1];
         byte[] packet2 = new byte[] {0, byte(myId)};
         client.write(packet2);
       }
     }  
  }
  
  // --- Spielablauf-Methode ---
  

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
