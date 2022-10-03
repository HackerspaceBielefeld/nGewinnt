## nGewinnt
Server written in Typescript
Client written in Flutter

### Build & Run

#### Client
1. Clone repo
2. cd to nGewinnt/ngewinntclient
3. edit main.dart and change endpoint
4. run `flutter pub get`
5. run `flutter build web --base-href /client/` (if you are using an reverseproxy, you will have to change the base-href)

#### Server
1. Clone repo
2. cd to nGewinnt/ngewinntserver
3. run `npm install`
4. copy built clientfiles (ngewinntclient/build/web/) to htmlclient
5. edit app.ts and set infos
6. run `npm run dev`
