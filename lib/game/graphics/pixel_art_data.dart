import 'package:flutter/material.dart';

/// Define un sprite de pixel art de alta precisión basado en una matriz de caracteres.
class PixelSpriteData {
  final int width;
  final int height;
  final List<String> matrix;
  final Map<String, Color> palette;

  const PixelSpriteData({
    required this.width,
    required this.height,
    required this.matrix,
    required this.palette,
  });
}

/// Contiene las matrices de Pixel Art detalladas para personajes, enemigos,
/// edificios de la aldea y elementos del mapa.
class PixelArtLibrary {
  // ==========================================
  // PALETAS COMUNES
  // ==========================================
  static const Color cTrans = Colors.transparent;
  static const Color cBlack = Color(0xFF141419);
  static const Color cSkin = Color(0xFFFFCC99);
  static const Color cSkinShadow = Color(0xFFE5A672);

  // ==========================================
  // 1. CABALLERO / PALADÍN (KNIGHT) - 16x16
  // ==========================================
  static final PixelSpriteData knightIdle = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'r': const Color(0xFFD90429), // Pluma roja del yelmo
      's': const Color(0xFFC0C0D0), // Metal plateado
      'S': const Color(0xFFE8E8F0), // Brillo metal
      'd': const Color(0xFF707088), // Sombra metal
      'g': const Color(0xFFFFD166), // Oro adorno
      'b': const Color(0xFF1D3557), // Capa azul
      'B': const Color(0xFF457B9D), // Capa azul brillante
      'w': Colors.white,
      'e': const Color(0xFF101015), // Ojos en la visera
    },
    matrix: [
      '....###r###.....',
      '...#rrr#rrr#....',
      '..#ssSssssss#...',
      '..#s#e#ss#e#s#..',
      '..#ssSssssss#...',
      '..#ggddddddgg#..',
      '.#b#ssssssss#b#.',
      '#Bb#sggwwggs#bB#',
      '#Bb#ssswwsss#bB#',
      '.#b#ssssssss#b#.',
      '..#g########g#..',
      '...#ssssssss#...',
      '...#sdd##dds#...',
      '...#sdd##dds#...',
      '..#ssdd##ddss#..',
      '..############..',
    ],
  );

  static final PixelSpriteData knightAttack = PixelSpriteData(
    width: 18,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'r': const Color(0xFFEF233C),
      's': const Color(0xFFC0C0D0),
      'S': const Color(0xFFFFFFFF),
      'd': const Color(0xFF707088),
      'g': const Color(0xFFFFD166),
      'b': const Color(0xFF1D3557),
      'w': Colors.white,
      'e': const Color(0xFF101015),
    },
    matrix: [
      '....###r###...SS..',
      '...#rrr#rrr#..SS#.',
      '..#ssSssssss#.sS#.',
      '..#s#e#ss#e#s#sS#.',
      '..#ssSssssss#ssS#.',
      '..#ggddddddgg#sS#.',
      '.#b#ssssssss#bsS#.',
      '#Bb#sggwwggs#gg##.',
      '#Bb#ssswwsss#g#...',
      '.#b#ssssssss#b#...',
      '..#g########g#....',
      '...#ssssssss#.....',
      '...#sdd##dds#.....',
      '..#ssdd##dds#.....',
      '.#sssdd##ddss#....',
      '.#####..######....',
    ],
  );

  // ==========================================
  // 2. ARQUERA / CAZADORA (RANGER) - 16x16
  // ==========================================
  static final PixelSpriteData rangerIdle = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'h': const Color(0xFF2B9348), // Capucha verde
      'H': const Color(0xFF55A630), // Capucha clara
      'f': const Color(0xFFFFD166), // Pelo rubio
      'k': cSkin,                  // Piel
      'K': cSkinShadow,
      'e': const Color(0xFF007200), // Ojos verdes
      't': const Color(0xFF6B705C), // Túnica cuero verde/marrón
      'b': const Color(0xFF7F4F24), // Cinturón / Carcaj
      'B': const Color(0xFF936639), // Cuero claro
      'w': const Color(0xFFDDB892), // Botas
    },
    matrix: [
      '....########....',
      '...#HHHHHHHH#...',
      '..#HhhhhhhhhH#..',
      '..#H#k#fff#k#H#.',
      '..#Hk#e#f#e#kH#.',
      '..#HkkkkkkkkH#..',
      '..#H##ffff##H#..',
      '...#b#tttt#B#...',
      '..#Bb#tttt#bB#..',
      '..#bB#bbbb#Bb#..',
      '...#K#tttt#K#...',
      '...#b#ffff#b#...',
      '...#B#b##b#B#...',
      '...#B#b##b#B#...',
      '..#wwb####bww#..',
      '..####....####..',
    ],
  );

  static final PixelSpriteData rangerAttack = PixelSpriteData(
    width: 18,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'h': const Color(0xFF2B9348),
      'H': const Color(0xFF55A630),
      'f': const Color(0xFFFFD166),
      'k': cSkin,
      'e': const Color(0xFF007200),
      't': const Color(0xFF6B705C),
      'b': const Color(0xFF7F4F24),
      'B': const Color(0xFF936639),
      'w': const Color(0xFFDDB892),
      'a': const Color(0xFFB08968), // Arco de madera
      's': Colors.white,          // Cuerda
    },
    matrix: [
      '....########...a#.',
      '...#HHHHHHHH#..as.',
      '..#HhhhhhhhhH#.as.',
      '..#H#k#fff#k#H#as.',
      '..#Hk#e#f#e#kHas.',
      '..#HkkkkkkkkH#as.',
      '..#H##ffff##Has.',
      '...#b#tttt#B#has.',
      '..#Bb#tttt#bBas.',
      '..#bB#bbbb#Bbas.',
      '...#K#tttt#K#as.',
      '...#b#ffff#b#as.',
      '...#B#b##b#B#as.',
      '..#ww#b##b#ww#a#.',
      '..####....####....',
      '..................',
    ],
  );

  // ==========================================
  // 3. MAGO ARCANO (MAGE) - 16x16
  // ==========================================
  static final PixelSpriteData mageIdle = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'p': const Color(0xFF5A189A), // Túnica púrpura
      'P': const Color(0xFF7B2CBF), // Púrpura brillante
      'l': const Color(0xFF9D4EDD), // Resplandor
      'g': const Color(0xFFFFD166), // Estrella dorada
      'k': cSkin,
      'b': const Color(0xFFE0AAFF), // Barba canosa/mágica
      'e': const Color(0xFF00F5D4), // Ojos de maná brillante
      'w': const Color(0xFF3C096C), // Capucha fondo
      's': const Color(0xFF7F4F24), // Báculo
      'c': const Color(0xFF00BBF9), // Gema báculo
    },
    matrix: [
      '.....######.....',
      '....#PPggPP#....',
      '...#PppppppP#...',
      '..#PppPggPppP#..',
      '..#P#k#PP#k#P#..',
      '..#Pk#e##e#kP#..',
      '..#PkkbbbbkkP#c#',
      '...#PbbbbbbP#cc#',
      '..#PPbbbbbbPP#s#',
      '.#PllppppppllP#s',
      '.#PllppppppllP#s',
      '.#PPppppppppPP#s',
      '.#PPppppppppPP#s',
      '.#PppppppppppP#s',
      '#PPppppppppppPP#',
      '################',
    ],
  );

  // ==========================================
  // 4. CLÉRIGA / GUARDIANA (VALKYRIE) - 16x16
  // ==========================================
  static final PixelSpriteData clericIdle = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'g': const Color(0xFFFFB703), // Tiara/aureola dorada
      'G': const Color(0xFFFFE6A7),
      'h': const Color(0xFF8338EC), // Pelo violeta
      'k': cSkin,
      'e': const Color(0xFF3A86FF), // Ojos zafiro
      'w': Colors.white,           // Coraza blanca celestial
      'W': const Color(0xFFD6E2E9),
      'b': const Color(0xFF3A86FF), // Ribetes celestes
      'm': const Color(0xFF4A4E69), // Martillo sagrado
      'M': const Color(0xFFFFD166), // Runas del martillo
    },
    matrix: [
      '....###GG###....',
      '...#ggGGGGgg#...',
      '..#gGghhhhgGg#..',
      '..#g#k#hh#k#g#..',
      '..#hk#e##e#kh#..',
      '..#hkkkkkkkkh#..',
      '..#hhkkkkkkhh#..',
      '...#W#wwww#W#...',
      '..#WW#wb#w#WW#..',
      '.#gWW#bbbb#WWg#.',
      '..#WW#wwww#WW#..',
      '...#W#bbbb#W#...',
      '..#bW#wwww#Wb#..',
      '..#W##W##W##W#..',
      '..#WW#W##W#WW#..',
      '..####.##.####..',
    ],
  );

  // ==========================================
  // ENEMIGO 1: GOBLIN SAQUEADOR - 16x16
  // ==========================================
  static final PixelSpriteData goblin = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'g': const Color(0xFF55A630), // Piel verde
      'G': const Color(0xFF80B918), // Piel verde claro
      'd': const Color(0xFF2B9348), // Sombra piel
      'e': const Color(0xFFFF0054), // Ojos rojos
      't': const Color(0xFFF72585), // Oreja interior
      'b': const Color(0xFF6B4226), // Ropas cuero marrón
      'k': const Color(0xFFD4A373), // Daga mango
      'm': const Color(0xFFC0C0C0), // Daga metal
    },
    matrix: [
      '#t#..........#t#',
      '#tt##......##tt#',
      '.#tgG######Ggt#.',
      '..#gGGGGGGGGg#..',
      '..#g#e#GG#e#g#..',
      '..#gGG####GGg#..',
      '...#g#GGGG#g#...',
      '....#dddddd#....',
      '..#b#dddddd#b#..',
      '..#bb#bbbb#bb#..',
      '..#bb#bbbb#bb#m#',
      '...#b######b#mm#',
      '...#g######g#k#.',
      '...#g#....#g#...',
      '..#gg#....#gg#..',
      '..####....####..',
    ],
  );

  // ==========================================
  // ENEMIGO 2: ORCO BERSERKER - 18x18
  // ==========================================
  static final PixelSpriteData orc = PixelSpriteData(
    width: 18,
    height: 18,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'g': const Color(0xFF386641), // Verde orco oscuro
      'G': const Color(0xFF6A994E), // Verde orco músculo
      'r': const Color(0xFFBC4749), // Pintura de guerra roja
      'h': const Color(0xFF4A4E69), // Casco con pinchos
      'e': const Color(0xFFFFD166), // Ojos amarillos furia
      'w': Colors.white,           // Colmillos
      'c': const Color(0xFF7F4F24), // Armadura cuero
      'C': const Color(0xFF43281C), // Cuero oscuro
      'm': const Color(0xFF222222), // Garrote pesado
      'p': const Color(0xFF999999), // Pinchos garrote
    },
    matrix: [
      '....#h##h##h#.....',
      '..#hh########hh#..',
      '..#h#GGrrGG#h#....',
      '..#G#e#rr#e#G#....',
      '..#GGG#ww#GGG#....',
      '..#gGwwwwwwGg#....',
      '..#gggggggggg#....',
      '.#G#cccGGccc#G#...',
      '#GG#cCCCCCCc#GG#..',
      '#GG#cCCCCCCc#GG#p#',
      '#GG#cccccccc#GG#m#',
      '.#G#CCCCCCCC#G#pm#',
      '..#G########G#mmm#',
      '..#gGG####GGg#mmm#',
      '..#gGG####GGg#pm#.',
      '..#ggg####ggg##...',
      '.#gggg####gggg#...',
      '.#####....#####...',
    ],
  );

  // ==========================================
  // ENEMIGO 3: ESQUELETO TIRADOR - 16x16
  // ==========================================
  static final PixelSpriteData skeleton = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'b': const Color(0xFFE8E8E8), // Hueso blanco
      'B': const Color(0xFFF5F5F5), // Hueso brillo
      's': const Color(0xFFAAAAAA), // Hueso sombra
      'e': const Color(0xFFFF0054), // Ojo espectral rojo
      'c': const Color(0xFF4A4E69), // Harapos / Capa
      'w': const Color(0xFF8B5A2B), // Arco de madera
      'S': Colors.white,          // Cuerda
    },
    matrix: [
      '.....######.....',
      '....#BBBBBB#....',
      '...#BBbbbbBB#...',
      '...#B#e##e#B#...',
      '...#BBbbbbBB#...',
      '....#s####s#....',
      '....#b#bb#b#....',
      '..#c#bbbbbb#c#w#',
      '.#cc##bbbb##c#w#',
      '.#c#s#b##b#s#c#s',
      '..##s#b##b#s##ws',
      '....#s####s#..ws',
      '....#b####b#..w#',
      '...#bb####bb#...',
      '...#bb####bb#...',
      '..####....####..',
    ],
  );

  // ==========================================
  // ENEMIGO 4: NIGROMANTE OSCURO - 16x16
  // ==========================================
  static final PixelSpriteData necromancer = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'r': const Color(0xFF240046), // Túnica oscura
      'R': const Color(0xFF3C096C), // Púrpura sombrío
      'k': const Color(0xFFD8F3DC), // Rostro cadavérico pálido
      'e': const Color(0xFF70E000), // Ojos verde fuego vil
      'm': const Color(0xFF5A189A), // Manto
      'g': const Color(0xFF38B000), // Orbe verde vil flotante
      'G': const Color(0xFF70E000),
      's': const Color(0xFF4A4E69), // Báculo de hueso
    },
    matrix: [
      '.....######.....',
      '....#RRRRRR#....',
      '...#RrrrrrrR#...',
      '..#Rrr#kk#rrR#..',
      '..#Rr#e##e#rR#..',
      '..#Rrk#kk#krR#..',
      '..#RkkkkkkkkR#..',
      '...#R#rrrr#R#...',
      '..#RR#rmmr#RR#g#',
      '.#mRR#rmmr#RR#GG',
      '.#mRR#rrrr#RR#gs',
      '.#RRR#rrrr#RRR#s',
      '#RRRRrrrrrrRRRR#',
      '#RrrrrrrrrrrrrR#',
      '#RRRRRRRRRRRRRR#',
      '################',
    ],
  );

  // ==========================================
  // ENEMIGO 5: TITÁN DESTRUCTOR (BOSS) - 24x24
  // ==========================================
  static final PixelSpriteData bossTitan = PixelSpriteData(
    width: 24,
    height: 24,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'h': const Color(0xFF6A040F), // Cuernos demoníacos
      'H': const Color(0xFF9D0208),
      'b': const Color(0xFF2B2D42), // Piel de piedra volcánica
      'B': const Color(0xFF3D405B),
      'l': const Color(0xFFFF5400), // Grietas de magma ardiente
      'L': const Color(0xFFFFB703), // Fuego volcánico interior
      'e': const Color(0xFFFFF3B0), // Ojos de fuego blanco
      'a': const Color(0xFF14213D), // Placas de hierro negro
      'x': const Color(0xFF9D0208), // Hacha sangrienta
      'X': const Color(0xFFD00000),
    },
    matrix: [
      '#h#..................#h#',
      '#Hh#................#hH#',
      '.#Hh##............##hH#.',
      '..#Hhh############hhH#..',
      '..#hhhhBBBBBBBBBBhhhh#..',
      '...#hhBbbbbbbbbBbbhh#...',
      '...#B#e##bbllobb##e#B#..',
      '...#BBb#e#bllb#e#bBB#...',
      '..#BBBbbblLLLllbbbBBB#..',
      '..#BBbbbb#llll#bbbbBB#..',
      '.#a#BBbbbbbbbbbbbbBB#a#.',
      '#aa#BBbblLllLllbbBB#aa#.',
      '#aa#aBBbbllLllbbBBa#aa#X',
      '#aa#aaBBbblllbbBBaa#aaXX',
      '.#a#aaBBBbbbbBBaa#a#xXXX',
      '..##aaBBBbbbbBBaa##.xXXX',
      '...#aaBBBbbbbBBaa#..xXX#',
      '...#aaBBBbbbbBBaa#...#X#',
      '...#aaBB#....#BBaa#...##',
      '...#aaBB#....#BBaa#.....',
      '..#aaaBB#....#BBaaa#....',
      '..#aaaBB#....#BBaaa#....',
      '.#aaaaBB#....#BBaaaa#...',
      '.########....########...',
    ],
  );

  // ==========================================
  // EDIFICIO 1: CORAZÓN DE LA ALDEA (TOWN HALL) - 24x24
  // ==========================================
  static final PixelSpriteData townHall = PixelSpriteData(
    width: 24,
    height: 24,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'r': const Color(0xFFD62828), // Tejado de tejas rojas
      'R': const Color(0xFFF77F00), // Brillo tejado
      'd': const Color(0xFF9D0208), // Sombra tejas
      'w': const Color(0xFFDDA15E), // Madera de las paredes
      'W': const Color(0xFFBC6C25), // Vigas de madera
      's': const Color(0xFF6C757D), // Muros de piedra base
      'S': const Color(0xFFADB5BD), // Piedra clara
      'g': const Color(0xFFFFD166), // Ventanas iluminadas / farol
      'b': const Color(0xFF1D3557), // Estandarte azul
      'B': const Color(0xFF457B9D),
      'c': const Color(0xFF495057), // Chimenea
      'p': const Color(0xFFE9ECEF), // Humo de chimenea
    },
    matrix: [
      '.........pp.............',
      '........ppp.............',
      '.......#cc#.............',
      '.......#cc#...#r#.......',
      '......##cc####rrr##.....',
      '.....#rrrrrrrrrrrrr#....',
      '....#rrrrrrrrrrrrrrr#...',
      '...#rrrrrrrrrrrrrrrrr#..',
      '..#rrrrdrdrdrdrdrdrrrr#.',
      '.#RRRRRRRRRRRRRRRRRRRR#.',
      '.#dddddddddddddddddddd#.',
      '..#WwWwWwWwWwWwWwWwWw#..',
      '..#w#g#w#bB#w#bB#w#g#w#.',
      '..#W#g#W#bB#W#bB#W#g#W#.',
      '..#w###w#bb#w#bb#w###w#.',
      '..#WwWwWwWwWwWwWwWwWw#..',
      '..#SSSSSSSSSSSSSSSSSS#..',
      '..#SsSsSs#WWWW#sSsSsS#..',
      '..#sSsSsS#WgWW#SsSsSs#..',
      '..#SsSsSs#WWWW#sSsSsS#..',
      '..#sSsSsS#WWWW#SsSsSs#..',
      '..#SSSSSS#WWWW#SSSSSS#..',
      '..#ssssss#WWWW#ssssss#..',
      '..####################..',
    ],
  );

  // ==========================================
  // EDIFICIO 2: TORRE DE GUARDIA DEFENSIVA - 16x20
  // ==========================================
  static final PixelSpriteData watchtower = PixelSpriteData(
    width: 16,
    height: 20,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'r': const Color(0xFFB02A37), // Tejadillo
      'R': const Color(0xFFDC3545),
      'w': const Color(0xFFDDA15E), // Madera
      'W': const Color(0xFF9A5E2E), // Vigas
      's': const Color(0xFF6C757D), // Piedra
      'S': const Color(0xFF495057),
      'f': const Color(0xFFFFC107), // Fuego antorcha
      'F': const Color(0xFFFF5722),
    },
    matrix: [
      '......#R#.......',
      '....#RRRRR#.....',
      '...#rrrrrrr#....',
      '..#rrrrrrrrr#...',
      '..#WWWWWWWWW#...',
      '..#w#w#w#w#w#...',
      '.#F#WwWwWwW#F#..',
      '.#f#WWWWWWW#f#..',
      '..###W#w#W###...',
      '....#W#w#W#.....',
      '....#W#w#W#.....',
      '....#W#w#W#.....',
      '....#WwWwW#.....',
      '...#SSSSSSS#....',
      '...#S#S#S#S#....',
      '...#s#s#s#s#....',
      '...#SSSSSSS#....',
      '...#sSsSsSs#....',
      '..#SSSSSSSSS#...',
      '..###########...',
    ],
  );

  // ==========================================
  // EDIFICIO 3: CABAÑA DE ALDEANO - 16x16
  // ==========================================
  static final PixelSpriteData cottage = PixelSpriteData(
    width: 16,
    height: 16,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'r': const Color(0xFF7F4F24), // Techo de paja/madera
      'R': const Color(0xFF936639),
      'w': const Color(0xFFE9D8A6), // Muros de barro/madera
      'W': const Color(0xFFBB9457),
      'd': const Color(0xFF6B4226), // Puerta
      'g': const Color(0xFFFFD166), // Ventana
      's': const Color(0xFF6C757D), // Zócalo
    },
    matrix: [
      '.....#R#........',
      '....#RRR#.......',
      '...#RRRRR#......',
      '..#rrrrrrr#.....',
      '.#RRRRRRRRR#....',
      '#rrrrrrrrrrr#...',
      '#WWWWWWWWWWW#...',
      '#w#g#wWw#g#w#...',
      '#W#g#WwW#g#W#...',
      '#w###wWw###w#...',
      '#WWWW#d#WWWW#...',
      '#wWwW#d#wWwW#...',
      '#WWWW#d#WWWW#...',
      '#ssss#d#ssss#...',
      '#sssssssssss#...',
      '#############...',
    ],
  );

  // ==========================================
  // DECORACIÓN: ÁRBOL FRONDOSO - 16x18
  // ==========================================
  static final PixelSpriteData forestTree = PixelSpriteData(
    width: 16,
    height: 18,
    palette: {
      '.': cTrans,
      '#': cBlack,
      'g': const Color(0xFF2D6A4F), // Copa árbol
      'G': const Color(0xFF40916C), // Copa brillante
      'd': const Color(0xFF1B4332), // Sombra hojas
      't': const Color(0xFF52B788), // Brillo alto
      'w': const Color(0xFF7F4F24), // Tronco
      'W': const Color(0xFF582F0E), // Tronco oscuro
    },
    matrix: [
      '.....######.....',
      '...##ttGGtt##...',
      '..#ttGGGGGGtt#..',
      '.#GGGGGGGGGGGG#.',
      '#GGGGddddGGGGGG#',
      '#GGddddddddGGGG#',
      '#GGddGGGGddddGG#',
      '.#GGGGGGGGGGGG#.',
      '..#dGGddddGGd#..',
      '...#dddddddd#...',
      '.....#WwwW#.....',
      '.....#WwwW#.....',
      '.....#WwwW#.....',
      '.....#WwwW#.....',
      '....#WWwwWW#....',
      '...#WWWwwWWW#...',
      '..#WWWWwwWWWW#..',
      '..############..',
    ],
  );
}
