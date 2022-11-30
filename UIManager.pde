public class UIManager {

  // --- Attribute (Objektvariablen) ---

  public ArrayList<Button> buttons = new ArrayList<Button>();

  // ---- Methoden ----

  public void input() {
    for (Button bt : buttons) {
      if (bt.input())
        return;
    }
  }

  public void render() {
    for (Button bt : buttons) {
      if (!bt.caninteract)
        continue;
      bt.render();
    }
  }

  public void register(Button button) {
    buttons.add(button);
  }

  public void setState(int i, boolean state) {
    buttons.get(i).caninteract = state;
  }
}

public abstract class Button {

  // --- Attribute (Objektvariablen) ---

  public int x = 0;
  public int y = 0;
  public int w = 0;
  public int h = 0;
  public int s = 0;
  public boolean caninteract = true;
  public boolean textlocked = false;
  public boolean show = false;
  public String text;
  public String textbackup;

  // --- Konstruktoren ---

  public Button(int x, int y, int w, int h, String text, int s) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.s = s;
    this.text = text;
  }

  // --- Reset-Methode ---

  public void reset() {
    show = false;
    text = null;
  }

  // --- Setter ---

  public void setText(String text) {
    this.text = text;
  }

  // --- Methoden ---

  public void render() {
    stroke(#FFFFFF);
    strokeWeight(5);
    fill(#F5D100);
    if (mouseX > x && mouseX < x+w) {
      if (mouseY > y && mouseY < y+h) {
        fill(#F2F702);
      }
    }
    rect(x, y, w, h);
    fill(0);
    textSize(s);
    textAlign(CENTER, CENTER);
    text(text, x, y, w, h);
    textSize(20);
    textAlign(TOP, LEFT);
  }

  public boolean input() {
    if (!caninteract)
      return false;

    if (mouseX > x && mouseX < x+w) {
      if (mouseY > y && mouseY < y+h) {
        onClick();
        return true;
      }
    }
    return false;
  }

  public abstract void onClick();
}

// ----------------------- Buttons ------------------------------

public class MultiplayerButton extends Button {

  // --- Konstruktoren ---

  public MultiplayerButton(int x, int y, int w, int h, String text, int s) {
    super(x, y, w, h, text, s);
  }

  // --- Methoden ---

  public void onClick() {
    programmstart = 60 * 3 + 2;
    caninteract = false;
    uim.buttons.get(1).caninteract = true;
    uim.buttons.get(2).caninteract = true;
    uim.buttons.get(6).caninteract = true;
  }
}

public class ReturnButton extends Button {

  // --- Konstruktoren ---

  public ReturnButton(int x, int y, int w, int h, String text, int s) {
    super(x, y, w, h, text, s);
  }

  // --- Methoden ---

  public void onClick() {
    caninteract = false;
    uim.buttons.get(2).caninteract = false;
    uim.buttons.get(2).reset();
    uim.buttons.get(3).caninteract = false;
    uim.buttons.get(4).caninteract = false;
    uim.buttons.get(5).caninteract = false;
    uim.buttons.get(6).caninteract = false;
    uim.buttons.get(6).reset();
    uim.buttons.get(0).caninteract = true;
    if (programmstart == 60 * 3 + 4) {
      ((SpielManagerClient)manager).disconnect();
      gamemode(0, null);
    }
    if (programmstart == 60 * 3 + 3) {
      ((SpielManagerHost)manager).disconnect();
      gamemode(0, null);
    }
    if (programmstart == 60 * 3 + 2) {
      gamemode(0, null);
    }
    programmstart = 0;
  }
}

public class TextBoxButton extends Button {

  // --- Konstruktoren ---

  public TextBoxButton(int x, int y, int w, int h, String text, int s) {
    super(x, y, w, h, text, s);
    textbackup = text;
  }

  // --- Reset-Methode ---

  public void reset() {
    show = false;
    text = textbackup;
    inventory.clear();
  }

  // --- Methoden ---

  public void onClick() {
    textlocked = false;
    text = show? text : "|";
    show = true;
    confirmOther(textbackup);
  }
}

public class HostButton extends Button {

  // --- Konstruktoren ---

  public HostButton(int x, int y, int w, int h, String text, int s) {
    super(x, y, w, h, text, s);
  }

  // --- Methoden ---

  public void onClick() {
    programmstart = 60 * 3 + 3;
    caninteract = false;
    uim.buttons.get(2).caninteract = false;
    uim.buttons.get(4).caninteract = false;
    uim.buttons.get(6).caninteract = false;
    uim.buttons.get(5).caninteract = true;
    gamemode(1, null);
  }
}

public class JoinButton extends Button {

  // --- Konstruktoren ---

  private TextBoxButton ipBox;

  public JoinButton(int x, int y, int w, int h, String text, int s, TextBoxButton textBox) {
    super(x, y, w, h, text, s);
    this.ipBox = textBox;
  }

  // --- Methoden ---

  public void onClick() {

    programmstart = 60 * 3 + 4;
    caninteract = false;
    uim.buttons.get(2).caninteract = false;
    uim.buttons.get(3).caninteract = false;
    uim.buttons.get(6).caninteract = false;
    jointext = "Warte auf Host";
    gamemode(2, ipBox.text);
  }
}

public class StartButton extends Button {

  // --- Konstruktoren ---

  public StartButton(int x, int y, int w, int h, String text, int s) {
    super(x, y, w, h, text, s);
  }

  // --- Methoden ---

  public void onClick() {
    programmstart = 60 * 3;
    caninteract = false;
    uim.buttons.get(1).caninteract = false;
  }
}
