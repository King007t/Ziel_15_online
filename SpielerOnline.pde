public class OnlineSpielerReciever extends Spieler {

  public int index;

  // --- Konstruktoren ---

  public OnlineSpielerReciever(String name, int index) {
    super(name);
    this.index = index;
  }

  // Empfaengt von einem Client
  public int pruefe() {
    if (!hideMessage) {
      meldeDaten(gibDaten());
      meldeDialog("Soll die eben geworfene " + aktWurf + " gewertet werden? Warte auf " + name + ".");
      hideMessage = true;
    }
    int val = manager.valBuffer;
    manager.valBuffer = 0;
    if (val == 1) {      
      hideMessage = false;
      delay(1000);
    }
    if (val == 2) {
      hideMessage = false;
      delay(1000);
    }
    return val;
  }

  // Wuerfeln, Wurfergebnis in aktWurf speichern.
  public void wuerfeln() {
    if (!bereitsGewuerfelt) {
      if (manager instanceof SpielManagerHost) {
        wuerfel.wuerfeln();
        aktWurf = wuerfel.getAugenzahl();  // speichert Augenzahl in aktWurf
        anzWuerfe++;
        bereitsGewuerfelt = true;
        boolean accepted = false;
        while (!accepted) {
          manager.serverRefresh();
          println("while");
          manager.sendPacket(4, 1, aktWurf);
          if (manager.list.size() > 0) {
            accepted = true;
            manager.list.clear();
          }
          delay(10);
        }
      } else if (manager instanceof SpielManagerClient) {
        boolean accepted = false;
        while (!accepted) {
          println("while");
          manager.clientRefresh();
          if (manager.aktWurfBuffer > 0) {
            aktWurf = manager.aktWurfBuffer;
            anzWuerfe++;
            manager.aktWurfBuffer = 0;
            bereitsGewuerfelt = true;
            accepted = true;
          }
          delay(10);
        }
      }
    }
  }
}

public class OnlineSpielerSender extends Spieler {

  // --- Konstruktoren ---

  public OnlineSpielerSender(String name) {
    super(name);
  }

  // Sendet an den Server
  public int pruefe() {
    println("prüfer aktiv");
    if (!hideMessage) {
      uim.buttons.get(7).caninteract = true;
      uim.buttons.get(8).caninteract = true;
      meldeDaten(gibDaten());
      meldeDialog("Soll die eben geworfene " + aktWurf + " gewertet werden? JA oder NEIN? ");
      hideMessage = true;
    }
    int val = 0;
    if (manager.werten >= 1) {
      val = manager.werten;
      manager.werten = 0;
      manager.sendPacket(4, manager.myId, val);
      hideMessage = false;
      delay(1000);
    }
    return val;
  }

  // Wuerfeln, Wurfergebnis in aktWurf speichern.
  public void wuerfeln() {
    if (!bereitsGewuerfelt) {
      boolean accepted = false;
      while (!accepted) {
        println("while");
        manager.clientRefresh();
        if (manager.aktWurfBuffer > 0) {
          aktWurf = manager.aktWurfBuffer;
          anzWuerfe++;
          manager.aktWurfBuffer = 0;
          bereitsGewuerfelt = true;
          accepted = true;
        }
        delay(10);
      }
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
      uim.buttons.get(7).caninteract = true;
      uim.buttons.get(8).caninteract = true;
      meldeDaten(gibDaten());
      meldeDialog("Soll die eben geworfene " + aktWurf + " gewertet werden? JA oder NEIN? ");
      hideMessage = true;
    }
    int val = 0;
    if (manager.werten >= 1) {
      val = manager.werten;
      manager.werten = 0;
      manager.sendPacket(4, 2, manager.myId, val);
      hideMessage = false;
      delay(1000);
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
      boolean accepted = false;
      while (!accepted) {
        manager.serverRefresh();
        println("whilehost");
        manager.sendPacket(4, 1, aktWurf);
        if (manager.list.size() > 0) {
          accepted = true;
          manager.list.clear();
        }
        delay(10);
      }
    }
  }
}
