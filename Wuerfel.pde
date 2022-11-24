public class Wuerfel {

  // --- Attribute (Objektvariablen) ---

  private int aktAugenzahl;
  private boolean gzn;

  // --- Konstruktoren ---
  public Wuerfel() {
    wuerfeln();
  }

  public Wuerfel(int aktAugenzahl) {
    this.aktAugenzahl = aktAugenzahl < 1 ? 1 : aktAugenzahl > 6 ? 6 : aktAugenzahl;
    gzn = true;
  }

  // --- getter-Methoden ---

  public boolean getGZN() {
    return gzn;
  }

  public int getAugenzahl() {
    return aktAugenzahl;
  }

  // --- setter-Methoden ---

  public void setAugenzahl(int augenzahl) {
    if (gzn) {
      aktAugenzahl = augenzahl < 1 ? 1 : augenzahl > 6 ? 6 : augenzahl;
    }
  }

  // --- Logik-Methoden ---

  public void wuerfeln() {
    if (!gzn) {
      aktAugenzahl = 1 + (int) (Math.random() * 6);
    }
  }
}
