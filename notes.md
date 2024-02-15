# Struktur / Syntax
## Modifier
1. was unterscheidet die modifier `private`, `protected`, `public`
  + Die sichtbarkeit von Feldern und Methoden für Unter- und Nicht-verwandte Klassen
2. was ist eine `final` variable

## Scopes
3. wo darf man methoden deklarieren
```java
        public class Klasse {
        => +
          static {
            println("Klasse wurde endlich geladen...")
          =>
          }
          public Klasse() {
            println("Leer!");
          =>
          }
        => +
        }
```
4. wo darf man Felder deklarieren
```java
        public class Klasse {
        => +
          static {
            println("Klasse wurde erfolgreich geladen!")
          =>
          }
          public Klasse() {
            println("Auch leer...");
          =>
          }
        => +
        }
```
5. wo darf man Methoden aufrufen
```java
        public class Klasse {
        =>
          static {
            println("Diese Klasse ist wirklich klasse.")
          => +
          }
          public Klasse() {
            println("Immernoch leer.")
          => +
          }
        =>
        }
```

# Typen

## Elementartypen
1. was passiert wenn man einen `double` wert zu `long` castet = `double a = 314.862735d; long b = (long) a;`
  + Die Gleitkommaziffern werden verworfen = `b = 314`
2. welcher code stimmt? `int len = array.length;` oder `long len = array.length();`
  + der erste, `length` ist ein Feld und keine methode

## Klassen
3. was fehlt hier: `equals method if instance of class { _______ }`
  + `Ware that = (Ware) other`
4. wie sieht eine instaziierung aus beim erstellen eines objektes für diese klasse:
  - `private Klasse(String name, int anzahl)`
  - `public Klasse(String name, int min, int max) { this(name, Random.rand(min, max))}`
  + `Klasse blub = new Klasse("Bob", 1, 10);`
5. welchen wert hat dieses statische feld am ende des programs:
  - `static int counter = 0; public Klasse() { this.init() } void init() { Klasse.counter++; printf("Neue Klasse erstellt, Anzahl: %d", Klasse.counter)}`
  - `4x neue klassen, dann 3x neue klassen in einem array`
  - `Klasse k1 = new Klasse();`
  - `Klasse[] klassenliste = { new Klasse(), new Klasse(), new Klasse() }`
  + `counter = 7`

# Beziehungen
## Vererbung
1. Ober- / Unterklassen = 
  - Die Unterklasse erbt alle _____ oder _____ Felder und Methoden der Oberklasse, eine nicht-verwandte Klasse kann nur auf _____ Felder und Methoden zugreifen
  + public, protected, public
2. super = welcher code stimmt mit dieser Oberklasse:
  - `public Oberklasse(String name)`
  - `public Klasse(String name, int alter) { super(name, alter) }`
  - `public Klasse(String name, int alter) { super(name) }`
  - `ein kontruktor wo super mit falscher reihenfolge der parameter gecalled wird und ein richtiger`

## Komposition
3. welcher code ist richtig:
```java
        Absender ich = new Absender();
        Empfaenger du = new Empfaenger();
        
        Email mail = new Email(ich, du);

        ---
      
        public class Email {
          Absender absender;
          Empfaenger empfaenger;

          public Email(Absender a, Empfaenger e) {
            this.absender = a;
            this.empfaenger = e;
          }

          ODER

          public Email() {
            this.setAbsender(ich);
            this.setEmpfaenger(du);
          }

          public setAbsender(Absender a) {
            this.absender = a;
          }
          public setEmpfaenger(Empfaenger e) {
            this.empfaenger = e;
          }
        }
```
  - `klasse Email mit references zu absender und empfänger iwie`
  + die untere variante ist falsch

## Interface
4. wozu braucht man Interfaces
  + mit interfaces lassen sich deklarationen und implementationen trennen, damit lässt sich code besser wieder benutzen
5. welche Aussagen zu Interfaces stimmen:
  - [ ] Interfaces können *keine* Klassen als Felder haben
  - [x] Felder können `static` sein (alle felder in einem Interface sind automatisch `public static final`)
  - [ ] Methoden können *nicht* überladen werden
  - [x] Interfaces können mehrere Unterklassen haben
      
# Umgebung
## Dateistruktur / Pakete
1. naming convention = was wäre die korrekte bennenung:
  - eine Klasse Rechner für ein Zinsrechner Projekt programmiert für eine Firma mit der Webadresse www.definitiv.legaler.zinsrechner.de
  + `de.zinsrechner.legaler.definitiv.zinsrechner.Rechner`
2. import = wenn `lang.test.Klasse`, kann sie mit `lang.*` importiert werden?
  + nein, das `*` gilt nur für klassen innerhalb des angegebenen Pakets, nicht aber für Unterklassen
3. class name resolving = iwas mit zwei klassen auf selbem level ob die sich trotzdem finden können
  - kann die Klasse `com.zinsrechner.Rechner` die Klasse `com.zinsrechner.Test` ohne ein import aufrufen?
  + ja da sie sich im selben Paket befinden
