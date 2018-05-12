# Funkcje systemu

## Użytkownicy systemu
- klient (osoba indywidualna) **ko**
- klient (firma) **kf**
- uczestnik konferencji (osoba indywidualna) **uko**
- uczestnik konferencji (osoba indywidualna, student) **ukos**
- pracownik firmy organizującej konferencje **pf**
- administrator **a**
- pracownik księgowości **pk**
- system **s**

## Przypadki użycia:
- tworzenie konferencji **pf**
- tworzenie warsztatu **pf**
- rejestracja na konferencję **ko**, **kf**
- uzupełnianie listy uczestników (konferencje, warsztaty) **ko**, **kf** - tylko dla swoich rejestracji **pf** - dla wszystkich rejestracji
- uiszczanie opłaty **ko**, **kf**
- anulowanie rezerwacji **s**
- usuwanie konferencji **pf**
- usuwanie warsztatu **pf**
- pobieranie identyfikatorów imiennych **ko**, **kf** - tylko dla swoich rejestracji **pf** - dla wszystkich rejestracji 
- pobieranie listy klientów do których należy zadzwonić w celu uzupełnienia danych **pf**
- pobieranie raportów **pf**
- pobieranie faktur **pk**
