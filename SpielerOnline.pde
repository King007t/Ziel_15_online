public class OnlineSpielerReciever extends Spieler {
  
  public int index;
  
  // --- Konstruktoren ---

  public OnlineSpielerReciever(String name, int index) {
    super(name);
    this.index = index;
  }
  
  // Empfaengt von einem Client
  public int pruefe() {
    manager.sendPacket(3, index, aktWurf);
    if (newPacket && packetAction != 0) {
      int action = packetAction;
      newPacket = false;
      packetAction = 0;
      return action;
    }
    return 0;
  }
}

public class OnlineSpielerSender extends Spieler {
  
  // --- Konstruktoren ---

  public OnlineSpielerSender(String name) {
    super(name);
  }
  
  // Sendet an den Server
  public int pruefe() {
    if (!hideMessage) {
      meldeDialog("Soll die eben geworfene " + aktWurf + " gewertet werden? JA(j) oder NEIN(n)? ");
      hideMessage = true;
    }
    int val = 0;
    if (keyPressed) {
      if (key == 'j') {
        meldeDialog("gewertet");
        val = 1;
        hideMessage = false;
        delay(1000);
      }
      if (key == 'n') {
        meldeDialog("nicht gewertet");
        val = 2;
        hideMessage = false;
        delay(1000);
      }
    }
    return val;
  }
  
  // Wuerfeln, Wurfergebnis in aktWurf speichern.
  public void wuerfeln() {
    if (!bereitsGewuerfelt) {
      
    }
  }
}

public class OnlineSpielerHost extends Spieler {
  
  // --- Konstruktoren ---

  public OnlineSpielerHost(String name) {
    super(name);
  }
  
  // Sendet an den Server
  public int pruefe() {
    if (!hideMessage) {
      meldeDialog("Soll die eben geworfene " + aktWurf + " gewertet werden? JA(j) oder NEIN(n)? ");
      hideMessage = true;
    }
    int val = 0;
    if (keyPressed) {
      if (key == 'j') {
        meldeDialog("gewertet");
        val = 1;
        hideMessage = false;
        delay(1000);
      }
      if (key == 'n') {
        meldeDialog("nicht gewertet");
        val = 2;
        hideMessage = false;
        delay(1000);
      }
    }
    return val;
  }
  
  // Wuerfeln, Wurfergebnis in aktWurf speichern.
  public void wuerfeln() {
    if (!bereitsGewuerfelt) {
      wuerfel.wuerfeln();
      aktWurf = wuerfel.getAugenzahl();  // speichert Augenzahl in aktWurf
      anzWuerfe++;
      bereitsGewuerfelt = true;
    }
  }
}
