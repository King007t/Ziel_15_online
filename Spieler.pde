public class Spieler {

  // --- Attribute (Objektvariablen) ---
  // online
  public boolean newPacket = false;
  public int packetAction = 0;

  // Beschreiben die Eigenschaften eines Spielers
  private String name;
  private int aktStand;
  private int aktWurf;
  private int anzWuerfe;
  private int anzGewertet;
  private boolean bereitsGewuerfelt;
  private boolean hideMessage;
  private int playertype;
  private Wuerfel wuerfel;

  // --- Konstruktoren ---

  // Konstruktor zur Erzeugung einzelner Spieler*innen fuer Ziel15.
  // Festlegung der Initialwerte der Attribute.
  // Ein Spielername wie "Horst" ist in "Anfuehrungszeichen" anzugeben.
  public Spieler(String name) {
    this.name = name;
    reset(0);
  }

  public Spieler(String name, int gznWurf) {
    this.name = name;
    reset(gznWurf);
  }

  // --- Reset-Methode ---

  // Nochmal von vorne anfangen: Alle Attributswerte
  // zuruecksetzen, damit nochmal gespielt werden kann.
  public void reset(int gzn) {
    aktStand    = 0;
    aktWurf     = 0;
    anzWuerfe   = 0;
    anzGewertet = 0;
    bereitsGewuerfelt  = false;
    hideMessage  = false;
    playertype = name.equals(manager.botName) ? 1 : name.equals(manager.onlineName) ? 2 : 0;
    wuerfel = gzn > 0 ? new Wuerfel(gzn) : new Wuerfel();
  }

  // --- getter-Methoden ---

  // Melden, ob das Spiel beendet ist, da 6 gewertete Wuerfe vorliegen
  public boolean istFertig() {
    return anzGewertet >= 6;
  }

  // get-Methode (Getter), die den Wert eines Attributs als
  // Antwort nach außen liefert
  public int getStand() {
    return aktStand;
  }

  // Getter, der den Wert des Attributs anzWuerfe als Antwort
  // nach außen liefert.
  public int getAnzWuerfe() {
    return anzWuerfe;
  }

  // Getter, der den Wert des Attributs aktWurf als Antwort
  // nach außen liefert. Koennte auch getAktWurf() heissen.
  public int getWurf() {
    return aktWurf;
  }


  // Getter, der den Wert des Attributs name als Antwort
  // nach außen liefert. Koennte auch getAktWurf() heissen.
  public String getName() {
    return name;
  }

  // Getter Methode welche angibt, ob der Wuerfel des aktSpielers
  // gezinkt ist
  public boolean getGZN() {
    return wuerfel.getGZN();
  }

  //--- setter-Methoden ---

  // set-Methode (Setter), die den Wert des Attributs name
  // neu zuweist. Eingabe ist der neue Name.
  public void setName(String name) {
    this.name = name;
  }

  // Setzt die aktAugenzahl auf einen mitgegeben Parameter
  public void setAugenzahl(int augenzahl) {
    wuerfel.setAugenzahl(augenzahl);
  }

  // --- Spiel-Methoden ---

  // Eine Spielrunde besteht aus wuerfeln(), entscheiden() und ggf. werten().
  public void spieleRunde() {
    wuerfeln();
    int entscheiden = entscheiden();
    if (entscheiden == 1) {
      werten();
      meldeDialog(gibDaten());
    } else if (entscheiden == 2) {
      meldeDialog(gibDaten());
    }
    if (entscheiden > 0) {
      bereitsGewuerfelt = false;
      manager.addtoSpieler(1);
      if (manager.akSpieler.size() <= manager.getSpieler()) {
        manager.setSpieler(0);
      }
      if (!(manager.akSpieler.get(manager.akSpieler.size() - 1).name == name && anzWuerfe >= 10)) {
        meldeDialog("------------------------------------");
        meldeDialog("Spieler " + (manager.getSpieler() + 1) + ": " + manager.akSpieler.get(manager.getSpieler()).name + " ist am Zug");
      }
    }
  }

  // Wurf pruefen und entscheiden, ob dieser Wurf gewertet wird
  // oder nicht. Beachtet, ob es moeglich ist, gibt Warnmeldungen aus,
  // Wertung erst nach einem Wurf moeglich und nur einmal.
  public int entscheiden() {
    if (istFertig()) {
      meldeDialog("Du hast bereits 6 Wuerfe gewertet");
      meldeDialog(gibDaten());
      delay(1000);
      return 3;
    } else if ((11 - anzWuerfe) <= (6 - anzGewertet)) {
      meldeDialog("Da erst " + anzGewertet + " von 6 Wuerfen gewertet wurden und du noch " + (10 - anzWuerfe) + " von 10 übrig"  );
      meldeDialog("hast, wird der Wurf gewertet.");
      delay(1000);
      return 1;
    } else {
      return pruefe();
    }
  }

  // Entscheidet wie entschieden wird.
  // Bei Mensch wertungsDialog oder bei Bot Zufallsausgabe.
  public int pruefe() {
    return playertype == 1 ? wertungsBot() : playertype == 2 ? onlineDialog(): wertungsDialog();
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

  // Fuehrt die eigentliche Wertung durch; aktualisiert den Stand;
  // zaehlt die Anzahl der gewerteten Wuerfe hoch,
  // verhindert erneute Wertung dieses Wurfes
  public void werten() {
    aktStand  += aktWurf;
    anzGewertet++;
  }

  // Interne Hilfsmethode, um Daten auszugeben. Ersetzt toString().
  public String gibDaten() {
    return ("Spieler: " + name + ";   Stand: " + aktStand + "/15;   AnzWuerfe: " + anzWuerfe + "/10;   AnzGewertet: "+ anzGewertet + "/6;");
  }

  // Interne Hilfsmethode für Dialogfenster der Entscheidung/Wertung.
  // Returned Die Entscheidung der*des Spieler*in, ob der Wurf
  // gewertet werden soll (true) oder nicht (false).
  public int wertungsDialog() {
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

  // Interne Hilfsmethode, um eine Zufallszahl 1 oder 2 auszugeben.
  public int worseWertungsBot() {
    int val = 1 + (int) (Math.random() * 2);
    String dialog = val == 1 ? "gewertet" : "nicht gewertet";
    meldeDialog(dialog);
    return val;
  }

  // Algorithmus, um effizient in der Nähe von 15, oder auf 15 zu landen.
  public int wertungsBot() {
    meldeDialog("Der Computer hat eine " + aktWurf + " gewuerfelt.");
    int diff = 15 - aktStand;
    int med = round(diff/ (6 - anzGewertet));
    if (anzGewertet == 5 && aktWurf == med) {
      meldeDialog("gewertet");
      return 1;
    } else if (aktWurf <= med && anzGewertet != 5) {
      meldeDialog("gewertet");
      return 1;
    } else {
      meldeDialog("nicht gewertet");
      return 2;
    }
  }

  public int onlineDialog() {
    if (newPacket && packetAction != 0) {
      int action = packetAction;
      newPacket = false;
      packetAction = 0;
      return action;
    }
    return 0;
  }
}
