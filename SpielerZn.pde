public class ZnSpieler extends Spieler {

  // --- Konstruktoren ---

  public ZnSpieler(String name, int gznWurf) {
    super(name);
    reset(gznWurf);
  }

  public void reset(int gzn) {
    aktStand    = 0;
    aktWurf     = 0;
    anzWuerfe   = 0;
    anzGewertet = 0;
    bereitsGewuerfelt  = false;
    hideMessage  = false;
    wuerfel = new Wuerfel(gzn);
  }
}
