import processing.net.*;

/**
 =================================
 |                               |
 |      Nick's Networking        |
 |                               |
 =================================
 **/

// --- Attribute (Objektvariablen) ---

public boolean isConnected = false;
public int programmstart = 0;
public String input;
public String input2;
public String jointext;
public int gamemode = 0;
public StringList inventory = new StringList();
public StringList inventory2 = new StringList();
public SpielManager manager;
public UIManager uim = new UIManager();

// --- Game Mode ---

// gamemode 0: offline | gamemode 1: host | gamemode 2: client
public void gamemode(int gamemode, String ip) {
  this.gamemode = gamemode;
  //println(ip);
  manager = gamemode == 1 ? new SpielManagerHost(): gamemode == 2 ? new SpielManagerClient(ip) : new SpielManager();
}

// --- Setup ---

void setup() {
  gamemode(0, null);
  size(600, 500, P3D);
  surface.setTitle("Ziel_15: Startbildschirm");
  uim.register(new MultiplayerButton(50, 400, 150, 50, "Multiplayer", 20));
  uim.register(new ReturnButton(50, 400, 150, 50, "Zurück", 20));
  uim.buttons.get(1).caninteract = false;
  uim.register(new TextBoxButton(170, 125, 250, 50, "Enter IP-Adress", 20));
  uim.buttons.get(2).caninteract = false;
  uim.register(new HostButton(170, 185, 120, 50, "Host", 20));
  uim.buttons.get(3).caninteract = false;
  uim.register(new JoinButton(300, 185, 120, 50, "Join", 20, (TextBoxButton)uim.buttons.get(2)));
  uim.buttons.get(4).caninteract = false;
  uim.register(new StartButton(400, 400, 150, 50, "Start", 20));
  uim.buttons.get(5).caninteract = false;
  uim.register(new TextBoxButton(170, 65, 250, 50, "Enter Name", 20));
  uim.buttons.get(6).caninteract = false;
}

// --- Draw ---

void draw() {
  if (width > 600 || height > 500) {
    surface.setSize(600, 500);
  }
  if (programmstart < 60 * 3) {
    backgroundImage();
    splashScreen();
    programmstart++;
  } else if (programmstart == 60 * 3 + 2) {
    multiplayerMenu();
  } else if (programmstart == 60 * 3 + 3) {
    hostMenu();

    if (manager == null)
      return;

    if (manager instanceof SpielManagerHost) {
      ((SpielManagerHost)manager).serverRefresh();
    } else if (manager instanceof SpielManagerClient) {
      ((SpielManagerClient)manager).clientRefresh();
    }
  } else if (programmstart == 60 * 3 + 4) {
    joinMenu();

    if (manager == null)
      return;

    if (manager instanceof SpielManagerClient) {
      ((SpielManagerClient)manager).clientRefresh();
    }
  } else {
    manager.spielAblauf();
    if (manager instanceof SpielManagerHost) {
      ((SpielManagerHost)manager).serverRefresh();
    } else if (manager instanceof SpielManagerClient) {
      ((SpielManagerClient)manager).clientRefresh();
    }
  }
  uim.render();
}

void mousePressed() {
  uim.input();
}

// --- Grafik-Methoden ---

public void backgroundImage() {
  // Hintergrund Farbe:
  noStroke ();
  background(#98DDFF);

  // Sonne:
  fill(#F2F702);
  ellipse(130, 80, 100, 100);

  // Wolken:
  fill(255);
  ellipse(450, 50, 100, 20);
  ellipse(430, 60, 100, 20);
  ellipse(470, 62, 100, 20);
  ellipse(270, 30, 100, 20);
  ellipse(250, 40, 100, 20);
  ellipse(290, 42, 100, 20);

  // Boden
  fill(#F2F702);
  rect(0, 283, 600, 217);

  // Hinterste Pyramide
  fill(#F2F702);
  triangle(302, 155, 285, 303, 413, 283);
  fill(#F5CD02);
  triangle(302, 155, 285, 303, 230, 285);

  // Hintere Pyramide
  fill(#F5CD02);
  triangle(220, 75, 40, 300, 160, 325);
  fill(#F5EF02);
  triangle(220, 75, 160, 325, 400, 290);

  // Vordere Pyramide
  fill(#F7B102);
  triangle(200, 100, 40, 300, 140, 330);
  fill(#FFD600);
  triangle(200, 100, 140, 330, 360, 300);

  // Kleine Pyramide 3
  fill(#F7B102);
  triangle(300, 250, 290, 329, 250, 320);
  fill(#F5CD02);
  triangle(300, 250, 290, 329, 350, 319);

  // Kleine Pyramide 2
  fill(#F7B102);
  triangle(215, 245, 150, 325, 200, 340);
  fill(#F5CD02);
  triangle(215, 245, 200, 340, 275, 330);

  // Kleine Pyramide
  fill(#F5C102);
  triangle(95, 240, 15, 340, 60, 355);
  fill(#F5CD02);
  triangle(95, 240, 60, 355, 165, 342);
}

public void splashScreen() {
  stroke(#FFFFFF);
  strokeWeight(5);
  fill(#F5D100);
  rect(100, 50, width - 2 * 100, height - 2 * 150);
  textSize(60);
  fill(#000000);
  text("Ziel 15", width / 2.75, height / 4);
  textSize(20);
  text("Processing Edition", width / 2.7, height / 3.5);
  text ("Weiter in " + (3 - (manager.getProgrammstart() / 60)), width / 2.4, height / 2.6);
  textSize(12.5);
  text("© Bozal, Balischewski, Heußer, Hörrle, Keibl, Kissel, Wunderlich, Jungblut", 110, height / 2.1);
  textSize(20);

  // Loading Box
  push();
  translate(width/(600/(600/1.83)), height/(500/(500/2.32)), width/(600/(600/3)));
  stroke(#000000);
  strokeWeight(1);
  fill(#FFFFFF);
  rotateY(manager.getProgrammstart()* 0.1);
  rotateX(manager.getProgrammstart()* 0.1);
  box(5);
  pop();
}

public void multiplayerMenu() {
  background(#98DDFF);
  fill(#F5D100);
  rect(100, 50, width - 2 * 100, height - 2 * 150);
  //fake host
  stroke(#FFFFFF);
  strokeWeight(5);
  fill(190);
  rect(170, 185, 120, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Host", 170, 185, 120, 50);
  textAlign(TOP, LEFT);
  fill(#F5D100);
  //fake join
  stroke(#FFFFFF);
  strokeWeight(5);
  fill(190);
  rect(300, 185, 120, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Join", 300, 185, 120, 50);
  textAlign(TOP, LEFT);
  fill(#F5D100);
  //
  enterIP();
  enterName();
  if (uim.buttons.get(6).textlocked )
    uim.buttons.get(3).caninteract = true;
  else
    uim.buttons.get(3).caninteract = false;
  if (uim.buttons.get(2).textlocked && uim.buttons.get(6).textlocked )
    uim.buttons.get(4).caninteract = true;
  else
    uim.buttons.get(4).caninteract = false;
}

public void hostMenu() {
  background(#98DDFF);
  fill(#F5D100);
  rect(100, 50, width - 2 * 100, height - 2 * 150);
  //fake start
  stroke(#FFFFFF);
  strokeWeight(5);
  fill(190);
  rect(400, 400, 150, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Start", 400, 400, 150, 50);
  textAlign(TOP, LEFT);
  fill(#F5D100);
  //
  textAlign(CENTER, CENTER);
  fill(0);
  textSize(30);
  if (isConnected) {
    uim.buttons.get(5).caninteract = true;
    int counter = 0;
    for (String s : ((SpielManagerHost)manager).clientMap.keySet()) {
      text(s, 100, 50*counter, width-2*100, height-2*150);
      counter++;
    }
  } else {
    uim.buttons.get(5).caninteract = false;
    text("Warte auf Spieler", 100, 50, width - 2 * 100, height - 2 * 150);
  }
  textSize(20);
  fill(#F5D100);
  textAlign(TOP, LEFT);
}

public void joinMenu() {
  background(#98DDFF);
  fill(#F5D100);
  rect(100, 50, width - 2 * 100, height - 2 * 150);
  textAlign(CENTER, CENTER);
  fill(0);
  textSize(30);
  if (jointext == "Das Spiel läuft bereits" ) {
    text(jointext, 100, 35, width - 2 * 100, height - 2 * 150);
    textSize(20);
    text("Zurück zum Menü in " + (3 - (manager.j / 60)), 100, 75, width - 2 * 100, height - 2 * 150);
  } else
    text(jointext, 100, 50, width - 2 * 100, height - 2 * 150);
  manager.j++;
  if (jointext == "Das Spiel läuft bereits" && manager.j == 60 * 3) {
    manager.client.stop();
    manager.reset();
    programmstart = 0;
  }
  textSize(20);
  fill(#F5D100);
  textAlign(TOP, LEFT);
}

public void enterIP() {
  if (uim.buttons.get(2).show == true) {
    if (keyPressed) {
      if (key == BACKSPACE) {
        if (inventory.size() != 0) {
          if (inventory.get(inventory.size() - 1).equals("."))
            inventory.remove(inventory.size() - 1);
          inventory.remove(inventory.size() - 1);
          //print
          if (inventory.size() == 0) {
            input = "|";
          } else {
            input = inventory.get(0);
            for (int i = 1; i < inventory.size(); i++) {
              input += inventory.get(i);
            }
          }
          uim.buttons.get(2).setText(input);
          delay(100);
        }
      } else if (key == ENTER) {
        confirmIp();
      } else if ((key == '0' || key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6' || key == '7' || key == '8' || key == '9') &&  inventory.size() < 15) {
        inventory.append(str(key));
        if (inventory.size() == 3 || inventory.size() == 7 || inventory.size() == 11)
          inventory.append(".");
        //print
        input = inventory.get(0);
        for (int i = 1; i < inventory.size(); i++) {
          input += inventory.get(i);
        }
        uim.buttons.get(2).setText(input);
        delay(100);
      }
    }
    // Loading Box
    push();
    translate(410, 172.5, 100);
    stroke(#000000);
    strokeWeight(1);
    fill(#FFFFFF);
    rotateY(millis()/700.0);
    rotateX(millis()/700.0);
    box(13);
    pop();
  }
}

void confirmIp() {
  uim.buttons.get(2).show = false;
  if (uim.buttons.get(2).text == "|" || uim.buttons.get(2).text.length() != 15) {
    uim.buttons.get(2).text = "Invalid IP-Adress";
  } else
    uim.buttons.get(2).textlocked = true;
  inventory.clear();
  delay(100);
}

public void enterName() {
  if (uim.buttons.get(6).show == true) {
    if (keyPressed) {
      if (key == BACKSPACE) {
        if (inventory2.size() != 0) {
          inventory2.remove(inventory2.size() - 1);
          //print
          if (inventory2.size() == 0) {
            input2 = "|";
          } else {
            input2 = inventory2.get(0);
            for (int i = 1; i < inventory2.size(); i++) {
              input2 += inventory2.get(i);
            }
          }
          uim.buttons.get(6).setText(input2);
          delay(100);
        }
      } else if (key == ENTER) {
        confirmName();
      } else if ((key == 'a' || key == 'b' || key == 'c' || key == 'd' || key == 'e' || key == 'f' || key == 'g' || key == 'h' || key == 'i' || key == 'j' || key == 'k' || key == 'l' || key == 'm' || key == 'n' || key == 'o' || key == 'p' || key == 'q' || key == 'r' || key == 's' || key == 't' || key == 'u' || key == 'v' || key == 'w' || key == 'x' || key == 'y' || key == 'z') &&  inventory2.size() < 10) {
        inventory2.append(str(key));
        //print
        input2 = inventory2.get(0);
        for (int i = 1; i < inventory2.size(); i++) {
          input2 += inventory2.get(i);
        }
        uim.buttons.get(6).setText(input2);
        delay(100);
      }
    }
    // Loading Box
    push();
    translate(410, 127.5, 100);
    stroke(#000000);
    strokeWeight(1);
    fill(#FFFFFF);
    rotateY(millis()/700.0);
    rotateX(millis()/700.0);
    box(13);
    pop();
  }
}

void confirmName() {
  uim.buttons.get(6).show = false;
  if (uim.buttons.get(6).text == "|" || uim.buttons.get(6).text.equals(manager.cheaterName) || uim.buttons.get(6).text.equals(manager.botName) || uim.buttons.get(6).text.equals(manager.onlineName)) {
    uim.buttons.get(6).text = "Invalid Name";
  } else
    uim.buttons.get(6).textlocked = true;
  inventory2.clear();
  delay(100);
}

void confirmOther(String text) {
  if (text == "Enter IP-Adress") {
    if (uim.buttons.get(6).text == "Enter Name")
      return;
    confirmName();
  }
  if (text == "Enter Name") {
    if (uim.buttons.get(2).text == "Enter IP-Adress")
      return;
    confirmIp();
  }
}

public void meldeDialog(String meldungstext) {
  if (manager.console.size() >= (height - 20) / 20) {
    manager.console.remove(0);
  }
  manager.console.append(meldungstext);
  backgroundImage();
  for (int i = 0; i < manager.console.size(); i++) {
    fill(#000000);
    text(manager.console.get(i), 20, 20 + 20 * i);
  }
}

public void refresh() {
  backgroundImage();
  for (int i = 0; i < manager.console.size(); i++) {
    fill(#000000);
    text(manager.console.get(i), 20, 20 + 20 * i);
  }
}
