# Kyvykkyysmittari

Six Sigma -prosessikyvykkyyden laskentatyökalu. Syötä mittaustuloksia, ja sovellus laskee automaattisesti:

- keskiarvon, sisäisen ja kokonaishajonnan
- Cp, Cpk, Pp, Ppk
- ohjausrajat (UCL/LCL) sekä toleranssirajat (USL/LSL)
- sigmatason ja DPMO/PPM
- histogrammin normaalikäyrällä, ohjauskortin ja vaihteluvälikortin

## Käyttö

Ei asennusta — avaa `index.html` suoraan selaimessa (tuplaklikkaus, tai GitHub Pages -osoite jos sivu on julkaistu). Ensimmäisellä kerralla luo tili sähköpostilla ja salasanalla. Data tallentuu omalle tilillesi, joten näet saman datan kaikilla laitteilla kunhan olet kirjautuneena samalla tunnuksella.

## Tekniikka

Yksi itsenäinen `index.html`-tiedosto (ei build-vaihetta, ei riippuvuuksia paitsi Supabase-JS-kirjasto CDN:stä ja Google Fonts). Data tallentuu [Supabaseen](https://supabase.com) (Postgres + Auth + Realtime):

- **Auth**: sähköposti+salasana, Supabase Authin oma järjestelmä.
- **Data**: `measurement_series`-taulu, rivikohtainen suojaus (Row Level Security) varmistaa että jokainen käyttäjä näkee ja muokkaa vain omia rivejään (`auth.uid() = user_id`).
- **Reaaliaikaisuus**: muutokset synkronoituvat välittömästi kaikkiin avoimiin näkymiin Supabase Realtimen kautta.

Koodissa näkyvä Supabase-projektin URL ja `anon`-avain ovat **tarkoituksella julkisia** — Supabase on suunniteltu niin, että tietoturva tulee tietokannan RLS-säännöistä, ei avaimen salaamisesta. Kukaan ei pääse toisen käyttäjän dataan käsiksi ilman tämän kirjautumistietoja.

## Oman version pystyttäminen

Jos haluat oman erillisen tietokannan:

1. Luo uusi projekti [supabase.com](https://supabase.com):ssa.
2. Aja `index.html`:n vieressä oleva `schema.sql` SQL-editorissa (luo taulun, RLS-säännöt ja realtime-julkaisun).
3. Korvaa `index.html`:n alusta löytyvät `SUPABASE_URL`- ja `SUPABASE_ANON_KEY`-vakiot omalla projektillasi (Project Settings → API).
