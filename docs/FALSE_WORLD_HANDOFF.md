# FALSE WORLD — FINAL GAME LOGIC HANDOFF

Version: 1.0 | Sana: 2026-11-01 | Til: Uzbek

**Holat: asosiy game logic kelishildi. Kod yozilgani yoki loyiha ishlayotgani bu hujjat bilan tasdiqlanmaydi.**

Bu hujjat oldingi v0.9 handoff va joriy suhbatda tasdiqlangan qarorlarni birlashtiradi. Qarama-qarshilik bo‘lsa, ushbu v1.0 dagi yangilangan qoida ustun. Aniq balans qiymatlari va texnik yechimlar prototipda belgilanadi. Yangi katta mexanika qo‘shishdan avval foydalanuvchi bilan kelishish kerak.

## 1. O‘yin mohiyati

FALSE WORLD — Godot 4.x / GDScript asosidagi third-person 3D multiplayer social-deception survival / psychological thriller.

Oddiy maqsad: **ikki qutulish nuqtasidan birini ishga tushir va yordam kelguncha tirik qol.**

4 haqiqiy inson va 22–25 odamga o‘xshagan AI bir xaritada boshlaydi. AI soni matchdan matchga o‘zgaradi; insonlarga aniq son va AI darajalari ko‘rsatilmaydi. Barcha AI bitta yashirin jamoa bo‘lib, insonlarning qutulishini to‘xtatishga urinadi. Alohida oddiy dushman moblar insonlarga ham, AI’larga ham xavf tug‘diradi.

Asosiy tuyg‘u: **yolg‘iz uddalash qiyin, lekin yordam berayotgan personajga ishonsa bo‘ladimi?**

Missiyalarni tushunish sodda. Qiyinchilik yurish, xavf, axborot yetishmasligi, ishonch va hamkorlikdan keladi. Yolg‘iz g‘alaba mumkin; kamida ikki inson talab qiladigan tugma, yuk yoki amal yo‘q. Jamoada qidirish, tashish, kuzatish va himoyani bo‘lishish osonroq. Yolg‘iz o‘yinchiga maxsus tezlik jazosi yoki avtomatik ko‘proq dushman yuborish yo‘q.

## 2. Qat’iy chegaralar

- Godot 4.x, GDScript, Git/GitHub. Codex va Antigravity o‘rtasida hujjatlar orqali davom ettirish.
- Budjet maqsadi 0 UZS; jami mutlaq chegara 100,000 UZS. Foydalanuvchi ruxsatisiz xarajat yoki pullik API/xizmat yo‘q.
- Faqat mo‘ljallangan foydalanishga, jumladan tijoriy foydalanishga ruxsat beradigan bepul assetlar. Har birining manbasi va litsenziyasi qayd etiladi.
- Windows, 16 GB RAM, Intel i5 va integratsiyalashgan grafikaga mos optimallashtirish. FPS/RAM maqsadlari hali o‘lchanmagan.
- Text-only chat. Voice chat yo‘q.
- Login, doimiy ranked/Elo tizimi, do‘kon, crafting, ochlik/chanqoq yoki boshqa so‘ralmagan tizimlar qo‘shilmaydi.
- Dastlabki prototip kichik; 1×1 km xarita va barcha agentlar birinchi kodlash vazifasi emas.

## 3. Personajlar va identifikatsiya

- Har matchda barcha human va AI’ga bir xil formatdagi, match ichida takrorlanmaydigan military-style ID beriladi; masalan F11, K72. Aniq format keyin tanlanadi.
- O‘yinchi nickname tanlamaydi. Alohida human/AI ID havzalari yo‘q.
- Model, animatsiya, chat, inventory va jang interfeysi rolni avtomatik oshkor qilmaydi.
- Human va AI bir xil jismoniy imkoniyatlar, HP, davolanish, loot, qurol, o‘q va interaction qoidalaridan foydalanadi.
- O‘lim banneri, jasad, loot yoki uzilish xabari human/AI rolini ochmaydi.
- 100% ajratib bo‘lmaslik va’da qilinmaydi: tashqi aloqa, kod so‘zlar va dialog imkoniyatlari bunga chegara qo‘yadi.

## 4. G‘alaba va match yakuni

Umumiy inson maqsadi — imkon qadar ko‘p insonning qutulishi; individual g‘alaba — o‘sha insonning o‘zi qutulishi.

| Holat | Natija |
|---|---|
| Bir yoki bir nechta inson qutuldi | Faqat qutulganlar g‘alaba oladi; qolganlar davom etadi |
| Barcha insonlar qutulgan yoki o‘lgan | Match tugaydi |
| Hech kim qutulmadi va barcha insonlar o‘ldi | AI to‘liq g‘alaba qiladi |
| Ayrimlar qutuldi, qolganlar o‘ldi yoki vaqti tugadi | Individual natijalar saqlanadi; AI qolganlarni to‘xtatgan hisoblanadi |
| Barcha AI o‘ldi | Avtomatik inson g‘alabasi yo‘q; qutulish kerak |
| Match vaqti tugadi | Qutulmaganlar yutqazadi; avvalgi g‘alabalar saqlanadi |

Match uchun ko‘rinadigan umumiy vaqt chegarasi bor. Qo‘shimcha vaqt yo‘q; qutulishni muddat ichida tugatish kerak. Muddat bilan aynan bir simulyatsiya vaqtida tugallangan qutulish avval hisoblanadi. Match natijasi bir marta chiqariladi.

**45 daqiqa tasdiqlangan qiymat emas.** Davomiylik xarita va missiya sinovidan keyin belgilanadi. Uzilgan insonning reconnect muddati ham matchni umumiy muddatdan oshirmaydi.

## 5. Ikki qutulish yo‘li

### 5.1 Tog‘ cho‘qqisi

Cho‘qqiga chiqish → u yerdagi favqulodda mayoqni qo‘lda ishga tushirish → yordam kelguncha tirik qolish → belgilangan hududda qutulish.

Stansiya qismlarini qidirish talab qilinmaydi. Ochiqroq va himoyalanish qiyinroq joylar xavf yaratadi. Cho‘qqiga yetishning o‘zi g‘alaba emas.

### 5.2 Signal stansiyasi

**Bitta akkumulyator + bitta radio modul** topish → istalgan tartibda o‘rnatish → signal yuborish → yordamni kutish → belgilangan hududda qutulish.

- Har qismning xaritada bir nechta nusxasi bo‘ladi; soni keyin belgilanadi.
- Bir inson ikkala qismni tashiy oladi.
- O‘rnatilgan qism qayta yechib olib ketilmaydi.
- Sabotajdan keyin yangi qismlar qidirilmaydi: mavjud qurilma ta’mirlanadi.
- Keyingi chaqiruvlarda qismlar qayta sarflanmaydi.
- Uzun retsept, kod qidirish va ko‘p bosqichli ortiqcha topshiriqlar yo‘q.

Ikkala yo‘l bir matchda ochiq va mustaqil ishlaydi. Bittasi xavfli bo‘lsa, ikkinchisiga o‘tish mumkin. Muhim joylarga imkon qadar bir nechta yondashuv yo‘li bo‘ladi.

### 5.3 Chaqiruv va qutulish qoidalari

- Chaqiruvni yuborish tugallanguncha qurilma sabotaj qilinishi va tiklanishi mumkin.
- **Chaqiruv muvaffaqiyatli yuborilgach, uni sabotaj bilan bekor qilib bo‘lmaydi.** Kutish davom etadi.
- Chaqiruvchi hududdan chiqsa yoki o‘lsa ham chaqiruv saqlanadi.
- Qutulish vaqti kelganda hududdagi barcha tirik insonlar avtomatik qutuladi; alohida tugma talab qilinmaydi.
- AI yonida turishi inson qutulishini bekor qilmaydi. AI qutulgan hisoblanmaydi; uning roli tiriklarga UI orqali oshkor etilmaydi.
- Hududda inson bo‘lmasa hech kim qutulmaydi; keyin yana chaqiruv yuborish mumkin.
- Birinchi guruhdan keyin qolganlar yangi chaqiruv bilan shu yo‘ldan foydalana oladi.
- Qutulgan insonning buyumlari chiqish joyida olinadigan loot bo‘lib qoladi; muhim buyumlar matchdan yo‘qolmaydi.
- Qutulish transporti, animatsiyasi, AI’ning shu vaqtdagi vizual holati va qayta chaqiruv sikli texnik/vizual yechim sifatida prototipda belgilanadi. Bunda rolni UI orqali oshkor qilmaslik qoidasi saqlanadi.

## 6. Interaction, ta’mir va sabotaj

- Har bir alohida ta’mirlash/o‘rnatish amalini bir vaqtda bitta personaj bajaradi. Boshqalar himoya yoki qidirish bilan yordam beradi; odam soni ish tezligini ko‘paytirmaydi.
- Amalni darhol bekor qilib qurol olish yoki qochish mumkin. Zarba amalni uzadi.
- Bajarilgan progress saqlanadi; boshqa personaj qolganidan davom ettira oladi.
- O‘rnatilayotgan buyum faqat tugallanganda sarflanib qurilmaga birikadi. Yarim amal buyumni yo‘qotmaydi va nusxalamaydi.
- AI yolg‘on yo‘l ko‘rsatish, guruhni ajratish, vaqt cho‘zish, real buyumni olish/tashish va pistirma bilan xalaqit beradi.
- Qurilmaga sabotaj uning yoniga kelib vaqt sarflash orqali bajariladi. Tiklash mumkin; barcha tugallangan ish bir zumda nolga tushmaydi.
- Muhim buyumlar yo‘q qilinmaydi yoki xaritadan tashqariga tashlanmaydi. Ular faqat belgilangan, yurib borib olish mumkin bo‘lgan loot joylariga tashlanadi. Bu cheklov inson va AI uchun bir xil.
- AI barcha qism nusxalarini jamlab, butun match berkitib saqlashni strategiya sifatida ishlatmaydi.
- Joyni qo‘riqlash mumkin, ammo ikkala yo‘lni mexanik jihatdan doimiy buzib qo‘yish mumkin emas. Bu g‘alaba kafolati emas: jang va vaqt sabab insonlar yutqazishi mumkin.

Sabotaj aynan qancha progressni o‘zgartirishi, davom ettirish nuqtalari va cooldownlar — sinov qarorlari; cheksiz o‘chirib-yoqish bilan oldinga siljishni imkonsiz qilishga yo‘l qo‘yilmaydi.

## 7. Axborot va chat

- O‘yin boshidan ikkala qutulish yo‘lining oddiy tartibi tushuntiriladi.
- Tog‘ va stansiya yo‘l belgilari hamda taniladigan joylar orqali topiladi. Qismning aniq koordinatasi avtomatik ochilmaydi.
- Yetishmayotgan qismlar va qutulishgacha qolgan vaqt qurilma yonida tekshiriladi.
- Chaqiruv yaqin atrofga ovoz yoki ko‘rinadigan belgi beradi. Butun xaritaga avtomatik mission bildirishnomasi yo‘q.
- Uzoqdagilar o‘z kuzatuvi yoki personajlarning gapiga tayanadi. Matchning umumiy taymeri esa hammaga ko‘rinadi.
- Kim o‘ldi/qutuldi degan global jonli ro‘yxat yo‘q.

Chat local/proximity text-only: xabar yuborilgan paytda masofa ichida bo‘lgan human va AI oladi. Keyin kelganlar oldingi suhbatni avtomatik olmaydi. Qabul qilingan xabarlar cheklangan tarixda saqlanadi; uzoqlashgan kishining yangi xabarlari kelmaydi.

Dastlab devor chatni to‘smaydi; masofa ishlaydi. Chat o‘yinni pauza qilmaydi; yopib darhol harakat/himoyaga qaytish mumkin. Yozayotgandagi aniq input boshqaruvi UI sinovida tanlanadi. Human va AI bir xil uslub, uzunlik va yuborish chekloviga bo‘ysunadi. Global chat, private message, voice va AI badge yo‘q. Chat masofasi hali belgilanmagan; avvalgi 5 metr misoli tasdiq emas.

## 8. Combat va HP

- PvP va PvAI bor. Dastlab musht, oddiy melee qurollari, pistolet va bir tur miltiq yetadi. Melee nisbatan ko‘p, firearms va o‘q juda kam.
- Qurolsiz himoya mumkin, ammo qurollangan raqibga qarshi xavfli.
- Cheklangan o‘q, qayta o‘qlash vaqti. Qayta o‘qlash uzilsa tugallanmagan amal o‘q qo‘shmaydi.
- Dastlab granata, zirh, murakkab combo yoki stamina tizimi yo‘q. Qochish/quvish muvozanati sinovdan o‘tadi.
- Barcha rollar bir xil combat tizimida zarar oladi. AI–AI friendly fire ham zarar yetkazadi.
- HP 0 bo‘lsa permanent death. Revive/respawn yo‘q.

### 8.1 Yangilangan avtomatik tiklanish

**Avtomatik regen bor.** Eski “auto regen yo‘q” va “faqat medkit” qoidalari bekor.

Oxirgi zarbadan keyin qisqa kutishdan so‘ng HP juda sekin tiklanadi. Yangi zarar tiklanishni to‘xtatib kutishni yangilaydi. Tirik personaj HP’si maksimumgacha tiklana oladi.

**Boshlang‘ich sinov tezligi: maksimal HP miqdori / 120 soniya.** Bu har bir jarohatdan keyin qat’iy 2 daqiqa degani emas. Masalan 100 maksimal HP bo‘lsa, 50 HP’dan to‘lish 60 soniya faol regen + boshlang‘ich kutish talab qiladi. 100 HPning o‘zi tasdiqlangan maksimal qiymat emas. 0 dan tiklanish yo‘q.

Kamyob medkit o‘ziga yoki yaqin personajga ishlatiladi, regen’dan ancha tez davolaydi. Vaqt talab qiladi, zarba/bekor qilish bilan uziladi, faqat tugallanganda sarflanadi. Ovqat yoki yangi regen resursi yo‘q. Human va AI uchun bir xil.

## 9. Insonlarga zarar uchun yashirin yakuniy jarima

Doimiy Elo/ranked tizimi kiritilmaydi. Match yakunidagi ball ayrilishi qo‘llanadi. Qoida o‘yinchilarga oldindan tushuntiriladi; aynan kim insonligi match davomida ball orqali tasdiqlanmaydi.

- Inson boshqa haqiqiy insonga birinchi bo‘lib zarar yetkazsa, uning tegishli zarari yakuniy jarimaga hisoblanadi.
- Hujum qilingan insonga shu hujumchiga qarshi vaqtinchalik self-defense oynasi ochiladi. Shu oynada qaytarilgan zarar jarimaga kirmaydi.
- Hujumchining yangi zarari himoya oynasini yangilaydi. Keyinroq borib qasos olish avtomatik himoya emas.
- Tasodifiy kichik tegishlar uchun kichik kechirim chegarasi bor; ketma-ket kichik zarbalar yig‘ilib hisoblanadi.
- Alohida o‘ldirish jarimasi zarar jarimasi ustiga qo‘shilmaydi.
- AI/mobga zarar uchun bu jarima yo‘q; ularni o‘ldirish uchun alohida kill bonusi ham yo‘q.
- Jarima, ball o‘zgarishi, rolni bildiruvchi ovoz yoki xabar match ichida ko‘rsatilmaydi. Faqat match yakunida ochiladi.
- Jarima qutulgan insonning g‘alabasini bekor qilmaydi, yakuniy balini kamaytiradi.
- Dastlab faqat bevosita yetkazilgan zarar hisoblanadi. Yolg‘on, mobni ergashtirish va boshqa bilvosita ayb avtomatik aniqlanmaydi.

Bu tizim niyatni mukammal aniqlamaydi. Provokatsiya, kichik zarbalar va himoya oynasini suiiste’mol qilish sinovdan o‘tishi kerak. Oyna ikki personaj o‘rtasida hisoblanadi; uchinchi odamga hujumni avtomatik oqlamaydi. Ball formulasi, kechirim chegarasi va vaqtlar prototipda belgilanadi. Avvalgi faqat final zarba egasiga kill jarimasi taklifi bekor.

## 10. Inventory, loot va o‘lim

- Qurol sig‘imi: 1 katta + 1 kichik. Inventory ichida qo‘shimcha zaxira qurol saqlab bu chegarani aylanib o‘tish yo‘q. Qurollarni aniq slotlarga ajratish keyin belgilanadi.
- Boshqa buyumlar cheklangan umumiy sig‘imdan foydalanadi. Ikkala mission qismini yolg‘iz tashish mumkin.
- Almashish buyumni ruxsat etilgan joyga tashlash orqali; savdo oynasi yo‘q.
- Bir buyum server tomonidan faqat bir marta beriladi; parallel pickup nusxalamaydi.
- Full death loot: barcha buyumlar qoladi. Jasad modeli olib tashlansa ham loot match oxirigacha olinadi; rol ko‘rsatilmaydi.
- Oddiy loot match ichida respawn qilmaydi. AI’lar o‘z qurol/o‘q/medkitini haqiqatan topib ishlatadi.
- Muhim buyum clipping yoki map chegarasi sabab yo‘qolsa, o‘sha buyum yaqin xavfsiz nuqtaga qaytariladi; nusxa yaratilmaydi. Oddiy o‘yin davomida AI buyumlarni teleport qila olmaydi.

## 11. Spectator

O‘lgan va qutulgan inson spectator bo‘ladi. Tirik personajlarning kamerasi orqali kuzatadi; erkin uchuvchi kamera yo‘q. Kuzatiladiganlar human va AI aralash; faqat humanlarni ajratib berish yo‘q.

Oddiy ko‘rinish va kuzatilayotgan personajga kelgan mahalliy chat ko‘rinadi; yashirin rol, inventory yoki AI ichki ma’lumoti ochilmaydi. Tiriklarga chat, ping yoki boshqa in-game signal yubora olmaydi. Match oxirida insonlar kimligi va individual natijalari ochiladi; AI darajalari ochilmaydi.

Tashqi Discord/Telegram orqali ma’lumot uzatishni to‘liq to‘xtatish kafolatlanmaydi.

## 12. AI tizimi

### 12.1 Darajalar va xulq

22–25 agent: Basic ko‘pchilik, Intermediate, Advanced kam. Aniq taqsimot sinovda belgilanadi; daraja tashqi ko‘rinishda bilinmaydi.

- Basic: loot, yurish, oddiy suhbat, himoya va sodda reja.
- Intermediate: vaziyatga mos aldash, xotira, hamkorlik.
- Advanced: ko‘p bosqichli aldash va rejalash; mukammal, o‘lmas yoki hamma narsani biladigan emas.

Adaptive strategy: kuzatish, rost yordam bilan ishonch qozonish, noto‘g‘ri yo‘naltirish, sabotaj, vaqt yutish, chekinish yoki jang. “Human ko‘rdim → hujum” qoidasi yo‘q. “Sen AI’san” degan gap ham majburiy agressiya triggeri emas. Agent mobdan insonni qutqarishi mumkin; bu insonlik isboti emas.

### 12.2 Bilim chegaralari

AI jamoadoshlarini taniydi. Ko‘rib ID’sini aniqlagan, jamoasiga kirmaydigan odamga o‘xshagan personajni human deb bilishi mumkin. Ammo odamlarning hozirgi joyi, HP, inventory, niyat va mission holati avtomatik berilmaydi.

Server truth va AI knowledge alohida. Perception yoki asosli xabar kerak. Kuzatuv kamida observer, subject (ma’lum bo‘lsa), event, position, time, confidence, source bilan qayd etiladi. Eski joy jonli GPS emas.

Agent → mahalliy xotira → kechiktirilgan/cheklangan Director report → freshness tekshiruvi → tegishli agentlarga topshiriq yoki ma’lumot. Ichki aloqa player-visible proximity chatdan alohida. Director agentni frame-by-frame masofadan boshqarmaydi.

Agent o‘z hayotini saqlash uchun topshiriqni to‘xtatishi mumkin; inson qutulishini to‘xtatish uchun hisoblangan xavf olishi mumkin. Barcha AI bir nishonga avtomatik yopirilmaydi; yo‘l vaqti va mavjud ma’lumot hisobga olinadi.

Teleport, cheksiz o‘q, devor ortidan jonli target tracking, mukammal avtomatik aim, collision bypass va ko‘rinmas inventory yo‘q. Path bloklansa qayta yo‘l izlaydi yoki vazifani tark etadi.

### 12.3 Dialogning amaliy chegarasi

Dastlab lokal contextual templates/intents va modular dialog adapter. Codex/Antigravity — ishlab chiqish yordamchilari, runtime miya emas. 22–25 agent uchun bepul human-level erkin suhbat yoki lokal LLM laptopda kafolatlanmaydi. AI aytgan gap real mexanika yaratmaydi va soxta system xabariga aylantirilmaydi. Keyingi model/API integratsiyasi alohida baholanadi; pullik xizmat avtomatik kiritilmaydi.

## 13. Oddiy dushman moblar

Dastlab bitta tur, kam sonli, ayrim belgilangan zonalarda. Turi/modeli hali tanlanmagan. Ular odamga o‘xshagan AI jamoasidan alohida; ularning yashirin strategik ittifoqchisi emas.

- Human va AI’ni bir xil sezish/zarar qoidalari orqali nishonlaydi; yashirin rolni bilmaydi.
- Bittasidan qochish yoki uni o‘ldirish nisbatan oson; e’tiborsiz qoldirish xavfli.
- Oddiy yurib yaqinlashadi, ovoz yoki harakat belgisi beradi. Orqada birdan spawn bo‘lib kafolatlangan o‘lim yaratmaydi.
- Interaction ovozi yaqin mobni jalb qilishi mumkin; har amal majburiy wave boshlamaydi.
- Personaj ishni to‘xtatib himoyalana oladi. AI ham mobni sezib qochadi yoki kurashadi; oldindan sehrli bilmaydi.
- Nishon yo‘qolsa yoki juda uzoqlashsa qidirishni to‘xtatib o‘z hududiga qaytadi. Butun xarita bo‘ylab cheksiz quvish yo‘q.
- Boshqaga ergashtirib olib borish mumkin; mob keyingi nishonni oddiy sezish/xavf qoidasi bilan tanlaydi.
- Dastlab match ichida o‘ldirilgan mob respawn qilmaydi.

## 14. Xarita va spawn

To‘liq birinchi gameplay xarita maqsadi: **1×1 km**. Abandoned/unfinished binolar, o‘rmon, yo‘llar, tog‘ va signal stansiyasi. Aniq zona joylashuvi, bino soni va vertikallik keyin belgilanadi.

Balanced random spawn: authored valid pointlardan tanlash. Insonlar odatda tarqoq; ayrim matchlarda ikkitasi yaqin chiqishi mumkin. AI hududlarga aralashadi. Devor ichida, mobning bevosita hujumida yoki qochib bo‘lmas instant-kill joyida boshlash yo‘q. Missiya qismi yoki qutulish qurilmasining bevosita ustida spawn yo‘q. Advanced agentlarni barcha human startlari yoniga tizimli joylashtirish yo‘q.

Boshlang‘ich 22–25 AI sonini yashirin tiklash uchun yangi agentlar avtomatik spawn qilinmaydi. Keyin qo‘shiladigan insonlar ham yo‘q.

Modular geometry, instancing, LOD, visibility culling ishlatilishi mumkin. Uzoq agentlarni optimallashtirish real yo‘l vaqti, axborot va buyum holatini buzmasligi kerak.

## 15. Aloqa uzilishi va reconnect

- Uzilgan insonning o‘sha personaji buyumlari bilan dunyoda qoladi, zarar olishi mumkin; AI takeover yo‘q.
- Cheklangan reconnect muddatida qaytsa, o‘sha personajga qaytadi. U o‘lgan bo‘lsa spectator bo‘ladi.
- Muddat tugasa personaj o‘ladi va looti qoladi.
- Match boshlanganidan keyin yangi inson tirik personaj bo‘lib qo‘shilmaydi; o‘z joyiga reconnect bundan mustasno.
- Host chiqib ketsa dastlab match tugaydi; host migration yo‘q. Bu normal gameplay g‘alabasi sifatida soxta hisoblanmasligi kerak; uzilgan matchni texnik tugash sifatida ko‘rsatish tafsiloti implementatsiyada belgilanadi.
- Global uzilish xabari yoki personaj belgisi inson rolini oshkor qilmaydi.
- Hosting va internet ulanish usuli hali tanlanmagan; doimiy public server bepul bo‘lishi kafolatlanmaydi.

## 16. Tavsiya etilgan modular arxitektura

Bu bo‘lim implementatsiya yo‘nalishi, mavjud kod tasdig‘i emas.

| Modul | Vazifa |
|---|---|
| Game Manager | Match lifecycle, timer, individual outcomes, yagona yakun |
| Shared Character | Motor, HP/regen, damage, equipment va interaction; farqi input manbasi |
| Inventory/Loot | Transactional pickup, drop, slots, corpse va critical item recovery |
| Objective System | Qism, progress, sabotage, call va extraction state |
| Perception/Memory | Mahalliy kuzatuv, beliefs, stale reports |
| AI Director | Cheklangan reportlar va strategik topshiriqlar |
| Agent Planner | Mavjud actionlar ichidan feasibility + utility bilan tanlash |
| Mob AI | Alohida, oddiy perception/chase/return |
| Chat Service | Bir xil proximity delivery va dialog adapter |
| Score Service | Human damage, self-defense, yakuniy maxfiy jarima |
| Networking | Authoritative identity, damage, loot, objectives, AI va reconnect |
| Spectator | Role-blind kuzatuv, tiriklarga aloqa yo‘q |

Network bosqichida server damage, range, movement, pickup, mission va AI state’ni tekshiradi. Clientlarga keraksiz yashirin is_ai flag, Director xotirasi yoki jonli human ro‘yxati uzatilmaydi. Local deterministik test, seed va loglar kerak.

## 17. Prototipda hal qilinadiganlar

Quyidagilar yangi katta mexanika emas; amalga oshirish va balans qarorlari:

- Maksimal HP, damage, melee reach, headshot/hit-zone qoidalari, aim reaction va medkit miqdori/vaqti.
- Regen uchun kutish; 120 soniya tezligini sinov natijasiga ko‘ra sozlash.
- Qurol slotlarining aniq klassifikatsiyasi, ammo turlari, inventory soni.
- Match davomiyligi, o‘rnatish/ta’mir/sabotaj/chaqiruv/kutish va takroriy chaqiruv vaqtlarining qiymatlari.
- Jarima va bazaviy natija ballari formulasi, self-defense oynasi, mayda zarar kechirim chegarasi; abuse testlari.
- Chat radiusi, history limiti, flood limiti, input/interaction tugmalari va UI.
- Critical part nusxalari soni, loot miqdori, spawn yaqinlik ehtimoli va xavfsiz masofalar.
- AI darajalari taqsimoti, report delay/expiry, Director dispatch, planner weights va dialog qamrovi.
- Mob modeli, soni, perception/leash masofasi va zarar qiymatlari.
- Reconnect muddati, networking/host usuli va interrupted-match natija taqdimoti.
- Xarita layouti, traversaldagi sakrash/qiyalik/collision tafsilotlari, extraction animatsiyasi, assetlar va performance benchmarklari.

Bu qiymatlarni so‘zlashuvda cheksiz aniqlashtirish shart emas. Dastlab taxminiy, konfiguratsiyalanuvchi qiymatlar bilan sinab ko‘riladi. O‘yin maqsadini o‘zgartiradigan qarorlar esa foydalanuvchiga qaytariladi.

## 18. Majburiy tekshiruv ssenariylari

1. Oxirgi tirik inson ikkala yo‘ldan ham yolg‘iz qutula olishi.
2. Jamoa vazifalarni bo‘lib foyda ko‘rishi; ikki kishi sharti yo‘qligi.
3. Bir guruh qutulgach qolganlar qayta chaqira olishi.
4. Chaqiruvchi o‘lsa/uzilsa va hudud bo‘shasa state buzilmasligi.
5. AI hududda turgani human extraction’ni bekor qilmasligi; UI role leak yo‘qligi.
6. Sabotaj tugallangan chaqiruvni bekor qilmasligi; cheksiz progress reset yo‘qligi.
7. Qism tashuvchi o‘lsa, qutulsa yoki buyum mapdan tushsa mission softlock bo‘lmasligi.
8. Parallel pickup/o‘rnatish/davolashda buyum va o‘q nusxalanmasligi.
9. HP 0 dan regen yo‘qligi; zarar kutishni qayta boshlashi; AI regen tengligi.
10. Self-defense, mayda zarbalarni yig‘ish va uchinchi shaxs holatlari; jarimaning jonli UI’da rolni ochmasligi.
11. Spectator/uzilish/log/chat orqali yashirin rol ochilmasligi.
12. AI last-seen holatidan foydalanishi; devor ortidan live GPS yo‘qligi.
13. Mob human va AI’ga teng xavf, warning, chase va return qoidalari.
14. Timer/extraction bir vaqtda tugashi va matchning bir marta yakunlanishi.
15. Host uzilishi, reconnect, permanent death va full loot mosligi.
16. Maqsadli laptopda FPS/RAM/navigation/AI update o‘lchovi.

## 19. Ishlab chiqish bosqichlari va amaldagi progress

**Tugallangan:** suhbatdagi asosiy game logic qarorlari va ushbu handoff sintezi. Hech qanday gameplay yoki multiplayer implementatsiyasi ushbu ish davomida qilinmagan.

**Tekshirilmagan:** avval so‘ralgan repository, Godot project, AGENTS.md, docs va uchta skill yaratilganmi. Mavjud deb da’vo qilinmasin.

Tavsiya etilgan ketma-ketlik:

1. Repo audit: mavjud fayllar, AGENTS.md, Godot versiyasi va progressni tekshirish. Ushbu qoidalar bilan docs/GAME_DESIGN.md, docs/GAME_LOGIC.md, docs/ARCHITECTURE.md va docs/PROGRESS.md’ni moslashtirish. .agents/skills/{godot-development,game-ai,game-testing} mavjudligini tekshirish. Skill yaratish faqat shu vazifa alohida topshirilganda.
2. Kichik 3D test sahna: third-person controller, kamera, interaction; vaqtinchalik sodda geometry.
3. 1 human + 3 AI: perception, xotira, Director, bir xil character imkoniyatlari, lokal chat va asosiy deception proof-of-concept.
4. Kichik playable: 6–8 AI, bir to‘liq qutulish yo‘li, combat/regen, inventory, bitta mob turi, spectator va yakuniy jarima.
5. 4 human network: authoritative state, reconnect va role leak testlari.
6. Ikki yo‘l, 1×1 km xarita va 22–25 AI maqsadiga bosqichma-bosqich chiqish; performance yetarliligini o‘lchash.
7. Balans, stability, credits/license audit va distribution qarorlari.

Har bir bosqichdan keyin PROGRESS.md’da bajarilgan ish, test, muammo va navbatdagi vazifa qayd etiladi. To‘liq game’ni birdan implementatsiya qilish topshirilmagan.

## 20. Yangi chat uchun tayyor prompt

> Biz FALSE WORLD o‘yinini davom ettiryapmiz. Biriktirilgan FALSE_WORLD_HANDOFF.md v1.0 ni to‘liq o‘qi. Asosiy logika kelishilgan; balans va texnik tafsilotlarni prototipda hal qilamiz. Qoidalarni boshidan qayta so‘rama va yangi katta mexanika qo‘shma. 4 human, 22–25 yashirin AI, ikki yakka/jamoaviy qutulish yo‘li, mahalliy text chat, kamyob firearms, bir katta va bir kichik qurol, medkit va sekin regen, permanent death/full loot, yashirin yakuniy human-damage jarimasi, ayrim zonalarda oddiy moblar bor. Godot 4.x/GDScript, bepul litsenziyali assetlar, laptop 16 GB RAM/integrated GPU. Hozir avval mavjud repository va AGENTS.md/PROGRESS.md’ni tekshir; nima haqiqatda borligini ayt. Hujjatga qarab kod bor deb taxmin qilma. So‘ng eng kichik navbatdagi prototip vazifasini taklif qil; gameplay kodini faqat tegishli vazifa berilgach yoz. Har bir tavsiyangda sabab va muhim kamchilikni qisqa ayt. Xarajat, yangi xizmat yoki to‘liq o‘yinni birdan yaratish yo‘q.

---

Bu yakuniy asosiy qoidalar hujjati, barcha texnik muammolar oldindan yechilgan degani emas. Prototip mavjud bo‘lmaguncha AI insondek gaplashishi, belgilangan hardware’da 22–25 agent va 1 km² xarita performance’i yoki online hosting natijasi kafolatlanmaydi.
