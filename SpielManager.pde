public class SpielManager {

  // --- Attribute (Objektvariablen) ---

  protected int spieler = 0;
  protected int mode = 0;
  protected int j = 0;
  protected int input3;
  public StringList console = new StringList();
  public ArrayList<Spieler> akSpieler = new ArrayList<Spieler>();
  protected Server server;
  protected Client client;

  // Bestimmt wer einen gezinkten Wuerfel erhält.
  private String cheaterName = "schwindler";

  // Bestimmt Spielername eines Bots.
  public String botName = "bot";

  // Bestimmt Spielername des Online Spielers.
  public String onlineName = "online";

  // --- Konstruktoren ---

  public SpielManager() {
    reset();
  }

  // --- Reset-Methode ---

  public void reset() {
    spieler = 0;
    mode = 0;
    j = 0;
    input = null;
    input2 = null;
    inventory.clear();
    console.clear();
    akSpieler.clear();
  }

  // --- getter-Methoden ---

  public int getProgrammstart() {
    return programmstart;
  }

  public int getMode() {
    return mode;
  }

  public int getSpieler() {
    return spieler;
  }

  public int getJ() {
    return j;
  }

  // --- setter-Methoden ---

  public void setSpieler(int val) {
    spieler = val;
  }

  // --- addto-Methoden ---

  public void addtoSpieler(int val) {
    spieler = spieler + val;
  }

  // --- Spielablauf-Methode ---

  public void spielAblauf() {
    if (programmstart == 60 * 3) {
      init();
      programmstart++;
    } else {
      if (keyPressed) {
        if (mode == 0) {
          setupSpieleranzahl();
        } else if (mode == 1 && j < Integer.valueOf(input)) {
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

  // --- Logik-Methoden ---

  protected void init() {
    surface.setTitle("Ziel_15: Einstellungen");
    meldeDialog("Wie viele Spieler?");
    meldeDialog("Spieleranzahl: ****");
    uim.setState(0, false);
  }

  public void setupSpieleranzahl() {
    if (key == BACKSPACE) {
      if (inventory.size() != 0) {
        inventory.remove(inventory.size() - 1);
        delay(100);
      }
    } else if (key == ENTER) {
      if (inventory.size() == 0) {
        inventory.append("1");
      }
      input = inventory.get(0);
      for (int i = 1; i < inventory.size(); i++) {
        input += inventory.get(i);
      }
      meldeDialog("Spieleranzahl: " + input);
      meldeDialog("------------------------------------");
      meldeDialog("Name Spieler 1?");
      meldeDialog("Name: ****");
      inventory.clear();
      mode++;
      delay(1000);
    } else if (key == '0' || key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6' || key == '7' || key == '8' || key == '9') {
      inventory.append(str(key));
      delay(100);
    }
  }

  public void setupName() {
    if (key == BACKSPACE) {
      if (inventory.size() != 0) {
        inventory.remove(inventory.size() - 1);
        delay(100);
      }
    } else if (key == ENTER) {
      if (inventory.size() == 0) {
        inventory.append("Spieler " + (j + 1));
      }
      input2 = inventory.get(0);
      for (int i = 1; i < inventory.size(); i++) {
        input2 += inventory.get(i);
      }
      if (input2.equals(cheaterName)) {
        meldeDialog( "Name: " + input2);
        meldeDialog("------------------------------------");
        meldeDialog("Gezinkter Wuerfel wert?");
        meldeDialog("Wert: ****");
        mode++;
      } else {
        upJbyOne();
      }
      delay(100);
    } else if (key == 'a' || key == 'b' || key == 'c' || key == 'd' || key == 'e' || key == 'f' || key == 'g' || key == 'h' || key == 'i' || key == 'j' || key == 'k' || key == 'l' || key == 'm' || key == 'n' || key == 'o' || key == 'p' || key == 'q' || key == 'r' || key == 's' || key == 't' || key == 'u' || key == 'v' || key == 'w' || key == 'x' || key == 'y' || key == 'z') {
      inventory.append(str(key));
      delay(100);
    }
  }

  public void setupZn() {
    if (key == ENTER) {
      if (input3 == 0) {
        input3++;
      }
      meldeDialog("Wert: " + input3);
      upJbyOne();
      delay(100);
    } else if (key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6') {
      input3 = Integer.valueOf(str(key));
      delay(100);
    }
  }

  public void setZn() {
    if (key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6') {
      akSpieler.get(spieler).setAugenzahl(Integer.valueOf(str(key)));
    }
  }

  public void upJbyOne() {
    j++;
    if (input3 > 0) {
      akSpieler.add(new Spieler(input2, input3));
      input3 = 0;
      mode -=1;
    } else {
      meldeDialog( "Name: " + input2);
      akSpieler.add(new Spieler(input2));
    }
    if (j < Integer.valueOf(input)) {
      meldeDialog("------------------------------------");
      meldeDialog("Name Spieler " + (j + 1) + "?");
      meldeDialog("Name: ****");
    }
    inventory.clear();
    input2 = null;
    if (j >= Integer.valueOf(input)) {
      if (2 > Integer.valueOf(input)) {
        akSpieler.add(new Spieler(botName));
        meldeDialog("------------------------------------");
        meldeDialog("Da das Spiel für zwei Spieler oder mehr gedacht ist,");
        meldeDialog("wird Spieler 2 durch den Computer übernommen.");
      }
      meldeDialog("------------------------------------");
      meldeDialog("SPIEL START:");
      meldeDialog("------------------------------------");
      meldeDialog("Spieler " + (spieler + 1) + ": " + akSpieler.get(spieler).name + " ist am Zug");
      mode += 2;
      println(mode);
    }
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
      reset();
      init();
    }
    if (dialog == 2) {
      surface.setTitle("Ziel_15: Spiel wird beendet");
      exit();
    }
  }

  public Spieler getWinner() {
    int maxVal = 0;
    Spieler maxSpieler = null;
    for (Spieler s : akSpieler) {
      if (maxSpieler == null) {
        maxSpieler = s;
        maxVal = abs(15 - maxSpieler.getStand());
        continue;
      }
      int abstand = abs(15 - s.getStand());
      if (abstand > maxVal) {
        continue;
      }
      if (abstand == maxVal) {
        return null;
      }
      maxVal = abstand;
      maxSpieler = s;
    }
    return maxSpieler;
  }

  public int dialog() {
    int val = 0;
    if (keyPressed) {
      if (key == 'j') {
        meldeDialog("JA");
        val = 1;
        delay(1000);
      }
      if (key == 'n') {
        meldeDialog("NEIN");
        val = 2;
        delay(1000);
      }
    }
    return val;
  }
  // --- wish abstract ---
  public void handlePacket(byte[] packet){}
  public void serverRefresh(){}
}
