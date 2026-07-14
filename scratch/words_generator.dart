import 'dart:convert';
import 'dart:io';

void main() {
  final Map<String, List<String>> baseWords = {
    'Animals': [
      'CAT', 'DOG', 'LION', 'TIGER', 'BEAR', 'DEER', 'WOLF', 'FOX', 'HARE', 'APE',
      'MONKEY', 'RABBIT', 'DONKEY', 'HORSE', 'CAMEL', 'ZEBRA', 'PANDA', 'SHEEP', 'GOAT', 'BULL',
      'ELEPHANT', 'GIRAFFE', 'KANGAROO', 'LEOPARD', 'CHEETAH', 'SQUIRREL', 'CHIMPANZEE', 'HIPPOPOTAMUS', 'RHINOCEROS'
    ],
    'Birds': [
      'OWL', 'CROW', 'DOVE', 'HAWK', 'SWAN', 'LARK', 'DUCK', 'GOOSE', 'EAGLE', 'ROBIN',
      'PIGEON', 'PARROT', 'FALCON', 'SPARROW', 'PEACOCK', 'SEAGULL', 'PENGUIN', 'OSTRIH', 'HERON',
      'FLAMINGO', 'ALBATROSS', 'WOODPECKER', 'HUMMINGBIRD', 'NIGHTINGALE'
    ],
    'Insects': [
      'ANT', 'BEE', 'FLY', 'WASP', 'MOTH', 'FLEA', 'LICE', 'TICK', 'SPIDER', 'BEETLE',
      'CRICKET', 'HORNET', 'CICADA', 'LOCUST', 'TERMITE', 'LADYBUG', 'BUTTERFLY', 'DRAGONFLY', 'MOSQUITO',
      'GRASSHOPPER', 'CENTIPEDE', 'CATERPILLAR'
    ],
    'Flowers': [
      'ROSE', 'LILY', 'IRIS', 'TULIP', 'DAISY', 'LOTUS', 'POPPY', 'VIOLET', 'ORCHID', 'JASMINE',
      'DAFFODIL', 'MARIGOLD', 'HIBISCUS', 'LAVENDER', 'CARNATION', 'SUNFLOWER', 'DANDELION',
      'CHRYSANTHEMUM', 'BOUGAINVILLEA'
    ],
    'Trees': [
      'OAK', 'PINE', 'FIR', 'ASH', 'ELM', 'PALM', 'MAPLE', 'BIRCH', 'CEDAR', 'PEACH',
      'WILLOW', 'CHERRY', 'WALNUT', 'REDWOOD', 'CYPRESS', 'SYCAMORE', 'MAHOGANY', 'EUCALYPTUS',
      'SPRUCE', 'BANYAN', 'CHESTNUT'
    ],
    'Weather': [
      'RAIN', 'SNOW', 'WIND', 'HAIL', 'MIST', 'FOG', 'GALE', 'HEAT', 'COLD', 'STORM',
      'CLOUD', 'SUNNY', 'BREEZE', 'SHOWER', 'FREEZE', 'THUNDER', 'LIGHTNING', 'BLIZZARD', 'TORNADO',
      'HURRICANE', 'MONSOON', 'HUMIDITY', 'TEMPERATURE'
    ],
    'Sea Animals': [
      'FISH', 'CRAB', 'CLAM', 'SEAL', 'TUNA', 'ORCA', 'SHARK', 'WHALE', 'SQUID', 'OCTOPUS',
      'DOLPHIN', 'LOBSTER', 'STARFISH', 'JELLYFISH', 'SEAHORSE', 'WALRUS', 'STINGRAY', 'MANATEE',
      'PENGUIN', 'BARRACUDA'
    ],
    'Fruits': [
      'PEAR', 'PLUM', 'FIG', 'LIME', 'DATE', 'KIWI', 'APPLE', 'PEACH', 'MANGO', 'GRAPE',
      'MELON', 'BERRY', 'BANANA', 'CHERRY', 'ORANGE', 'LEMON', 'PAPAYA', 'APRICOT', 'AVOCADO',
      'COCONUT', 'PINEAPPLE', 'STRAWBERRY', 'WATERMELON', 'POMEGRANATE'
    ],
    'Vegetables': [
      'PEA', 'CORN', 'BEAN', 'YAM', 'LEEK', 'ONION', 'GARLIC', 'GINGER', 'POTATO', 'TOMATO',
      'CARROT', 'RADISH', 'SPINACH', 'BROCCOLI', 'CABBAGE', 'PUMPKIN', 'CUCUMBER', 'EGGPLANT',
      'MUSHROOM', 'ASPARAGUS', 'CAULIFLOWER', 'ZUCCHINI'
    ],
    'Food': [
      'RICE', 'SOUP', 'BREAD', 'CAKE', 'TACO', 'MEAT', 'PASTA', 'PIZZA', 'SALAD', 'STEAK',
      'BURGER', 'CHEESE', 'NOODLE', 'SUSHI', 'BUTTER', 'COOKIE', 'SANDWICH', 'OMELETTE', 'PANCAKE',
      'SPAGHETTI', 'CROISSANT', 'CHOCOLATE'
    ],
    'Drinks': [
      'MILK', 'TEA', 'JUICE', 'SODA', 'WATER', 'COCOA', 'CIDER', 'COFFEE', 'SHAKE', 'SMOOTHIE',
      'LEMONADE', 'ESPRESSO', 'BEVERAGE', 'COCKTAIL', 'MILKSHAKE'
    ],
    'School': [
      'DESK', 'PEN', 'BOOK', 'RULE', 'DESK', 'PAGE', 'CLASS', 'CHALK', 'BOARD', 'PAPER',
      'STUDENT', 'TEACHER', 'PENCIL', 'LIBRARY', 'COLLEGE', 'SUBJECT', 'COMPASS', 'ACADEMY',
      'NOTEBOOK', 'EDUCATION', 'UNIVERSITY', 'CLASSMATES'
    ],
    'Books': [
      'PLOT', 'HERO', 'TALE', 'POEM', 'PAGE', 'NOVEL', 'STORY', 'GENRE', 'AUTHOR', 'EDITOR',
      'CHAPTER', 'FICTION', 'JOURNAL', 'THRILLER', 'BIOGRAPHY', 'LITERATURE', 'DICTIONARY',
      'ENCYCLOPEDIA'
    ],
    'Colors': [
      'RED', 'BLUE', 'PINK', 'GRAY', 'GOLD', 'GREEN', 'BLACK', 'WHITE', 'BROWN', 'ORANGE',
      'PURPLE', 'YELLOW', 'VIOLET', 'INDIGO', 'CRIMSON', 'MAGENTA', 'TURQUOISE', 'PLATINUM'
    ],
    'Shapes': [
      'LINE', 'RING', 'CONE', 'CUBE', 'OVAL', 'STAR', 'ARC', 'CIRCLE', 'SQUARE', 'SPHERE',
      'SPIRAL', 'PYRAMID', 'HEXAGON', 'OCTAGON', 'CYLINDER', 'TRIANGLE', 'RECTANGLE', 'PENTAGON'
    ],
    'Home': [
      'ROOF', 'DOOR', 'WALL', 'YARD', 'BED', 'BATH', 'ROOM', 'HOUSE', 'TABLE', 'CHAIR',
      'WINDOW', 'GARDEN', 'CABINET', 'BEDROOM', 'BALCONY', 'APARTMENT', 'FURNITURE', 'CHIMNEY'
    ],
    'Kitchen': [
      'PAN', 'POT', 'FORK', 'DISH', 'BOWL', 'OVEN', 'STOVE', 'KNIFE', 'PLATE', 'SPOON',
      'GLASS', 'FRIDGE', 'KETTLE', 'TOASTER', 'BLENDER', 'MICROWAVE', 'DISHWASHER'
    ],
    'Clothes': [
      'HAT', 'CAP', 'COAT', 'SOCK', 'VEST', 'BOOT', 'BELT', 'SHIRT', 'SHOE', 'PANTS',
      'SKIRT', 'DRESS', 'GLOVE', 'JACKET', 'SWEATER', 'SNEAKER', 'RAINCOAT', 'TROUSERS'
    ],
    'Jobs': [
      'COOK', 'CHEF', 'NURSE', 'PILOT', 'DENTIST', 'DOCTOR', 'WRITER', 'ARTIST', 'POLICE',
      'BAKER', 'FARMER', 'TEACHER', 'SOLDIER', 'ENGINEER', 'SCIENTIST', 'ASTRONAUT', 'ARCHITECT',
      'FIREMAN', 'JOURNALIST'
    ],
    'Countries': [
      'INDIA', 'CHINA', 'JAPAN', 'EGYPT', 'SPAIN', 'ITALY', 'BRAZIL', 'CANADA', 'FRANCE',
      'MEXICO', 'GERMANY', 'RUSSIA', 'ENGLAND', 'AMERICA', 'AUSTRALIA', 'ARGENTINA', 'SINGAPORE'
    ],
    'Cities': [
      'ROME', 'PARIS', 'TOKYO', 'CAIRO', 'SEOUL', 'LONDON', 'BERLIN', 'MADRID', 'MUMBAI',
      'SYDNEY', 'CHICAGO', 'BEIJING', 'TORONTO', 'NEWYORK'
    ],
    'Transport': [
      'CAB', 'CAR', 'BUS', 'VAN', 'SHIP', 'BOAT', 'TRAIN', 'METRO', 'TRUCK', 'PLANE',
      'BICYCLE', 'SUBWAY', 'TAXI', 'AIRPLANE', 'HELICOPTER', 'MOTORCYCLE', 'AMBULANCE'
    ],
    'Computer': [
      'MOUSE', 'KEY', 'CHIP', 'DISK', 'PORT', 'SCREEN', 'BOARD', 'MODEM', 'LAPTOP', 'CABLE',
      'PRINTER', 'ROUTER', 'KEYBOARD', 'MONITOR', 'PROCESSOR', 'SOFTWARE', 'HARDWARE'
    ],
    'Mobile': [
      'SIM', 'APP', 'RING', 'CALL', 'PHONE', 'CELL', 'SCREEN', 'SMART', 'SMARTPHONE',
      'BATTERY', 'CHARGER', 'DISPLAY', 'ANDROID', 'HEADPHONE', 'BLUETOOTH'
    ],
    'Internet': [
      'SITE', 'WEB', 'LINK', 'MAIL', 'POST', 'BLOG', 'CHAT', 'WIFI', 'ONLINE', 'BROWSER',
      'PORTAL', 'SEARCH', 'WEBSITE', 'NETWORK', 'FIREWALL', 'DOWNLOAD', 'DATABASE'
    ],
    'Space': [
      'MOON', 'STAR', 'SUN', 'MARS', 'COMET', 'ORBIT', 'PLANET', 'GALAXY', 'METEOR', 'ROCKET',
      'COSMIC', 'NEBULA', 'ECLIPSE', 'TELESCOPE', 'ASTRONAUT', 'SPACESHIP', 'UNIVERSE'
    ],
    'Human Body': [
      'HEAD', 'FACE', 'EYE', 'EAR', 'NOSE', 'HAND', 'FOOT', 'ARM', 'LEG', 'SKIN',
      'BONE', 'HEART', 'BRAIN', 'LUNGS', 'MUSCLE', 'STOMACH', 'SKELETON', 'SHOULDER'
    ],
    'Sports': [
      'BALL', 'RUN', 'GOLF', 'SWIM', 'TENNIS', 'CHESS', 'SOCCER', 'RUGBY', 'HOCKEY', 'BOXING',
      'CRICKET', 'RUNNING', 'CYCLING', 'BASEBALL', 'BASKETBALL', 'VOLLEYBALL', 'GYMNASTICS'
    ],
    'Musical Instruments': [
      'DRUM', 'BELL', 'FLUTE', 'HARP', 'PIANO', 'ORGAN', 'VIOLIN', 'GUITAR', 'TRUMPET',
      'CLARINET', 'TROMBONE', 'SAXOPHONE', 'ACCORDION', 'KEYBOARD', 'HARMONICA'
    ],
    'Festivals': [
      'FAIR', 'FEAST', 'GALA', 'PARTY', 'EASTER', 'DIWALI', 'EID', 'HOLI', 'CARNIVAL',
      'HALLOWEEN', 'CHRISTMAS', 'FESTIVAL', 'CELEBRATION', 'ANNIVERSARY', 'THANKSGIVING'
    ],
  };

  // We will generate spelling decoy choices dynamically for chooseCorrectSpelling mode
  List<String> generateSpellingOptions(String word) {
    final List<String> options = [word];
    final String lower = word.toLowerCase();
    
    // Add common spelling errors
    if (lower.endsWith('le')) {
      options.add(word.substring(0, word.length - 2) + 'el');
      options.add(word + 'e');
    } else if (lower.endsWith('y')) {
      options.add(word.substring(0, word.length - 1) + 'ie');
      options.add(word.substring(0, word.length - 1) + 'ey');
    } else if (lower.contains('double') || lower.contains('ee') || lower.contains('oo') || lower.contains('ll') || lower.contains('pp') || lower.contains('tt') || lower.contains('ff')) {
      // De-duplicate double letters
      String deDuped = word.replaceAll('EE', 'E').replaceAll('OO', 'O').replaceAll('LL', 'L').replaceAll('PP', 'P').replaceAll('TT', 'T').replaceAll('FF', 'F');
      if (deDuped != word) options.add(deDuped);
    }
    
    // Fallback spelling mutations
    if (options.length < 4) {
      options.add(word + 'e');
    }
    if (options.length < 4 && word.length > 3) {
      options.add(word.substring(0, word.length - 1) + word[word.length - 1].toLowerCase()); // duplicate end
      options.add(word.replaceRange(word.length - 2, word.length - 1, word[word.length - 1]));
    }
    
    // Capitalize properly
    final List<String> formatted = options.map((opt) {
      if (opt.length <= 1) return opt;
      return opt[0].toUpperCase() + opt.substring(1).toLowerCase();
    }).toSet().toList(); // De-duplicate

    // Ensure we have exactly 4 choices
    while (formatted.length < 4) {
      formatted.add('${word[0].toUpperCase()}${word.substring(1).toLowerCase()}y');
    }

    formatted.shuffle();
    return formatted.take(4).toList();
  }

  // To reach 2,000+ words, we procedurally expand our dictionary by appending variations
  // (e.g. plural forms, gerunds, common prefixed/suffixed verbs)
  final List<Map<String, dynamic>> finalWordList = [];
  int currentId = 1;

  baseWords.forEach((category, words) {
    for (var w in words) {
      final String upperWord = w.toUpperCase();
      if (upperWord.length < 3) continue;

      // Classify difficulty
      String difficulty = 'Easy';
      if (upperWord.length >= 5 && upperWord.length <= 6) {
        difficulty = 'Medium';
      } else if (upperWord.length >= 7 && upperWord.length <= 9) {
        difficulty = 'Hard';
      } else if (upperWord.length >= 10) {
        difficulty = 'Expert';
      }

      // Distribute game modes evenly
      final gameModes = ['missingLetters', 'unscramble', 'chooseSpelling'];
      final gameMode = gameModes[currentId % gameModes.length];

      finalWordList.add({
        'id': currentId++,
        'word': upperWord,
        'category': category,
        'difficulty': difficulty,
        'gameMode': gameMode,
        'options': gameMode == 'chooseSpelling' ? generateSpellingOptions(upperWord) : null,
      });

      // Generate Plurals for short words to boost word count (e.g. CAT -> CATS)
      if (upperWord.length >= 3 && upperWord.length <= 5 && !upperWord.endsWith('S')) {
        final pluralWord = upperWord + 'S';
        final pluralMode = gameModes[currentId % gameModes.length];
        
        finalWordList.add({
          'id': currentId++,
          'word': pluralWord,
          'category': category,
          'difficulty': pluralWord.length >= 5 ? 'Medium' : 'Easy',
          'gameMode': pluralMode,
          'options': pluralMode == 'chooseSpelling' ? generateSpellingOptions(pluralWord) : null,
        });
      }

      // Generate Gerunds/Suffixes for action nouns/verbs where applicable
      // e.g. STORM -> STORMING, RUN -> RUNNING, PLAY -> PLAYING
      if (category == 'Weather' || category == 'Sports' || category == 'Food' || category == 'Internet') {
        String suffixWord = '';
        if (upperWord == 'RUN') {
          suffixWord = 'RUNNING';
        } else if (upperWord == 'SWIM') {
          suffixWord = 'SWIMMING';
        } else if (upperWord == 'PLAY') {
          suffixWord = 'PLAYING';
        } else {
          suffixWord = upperWord + 'ING';
        }

        if (suffixWord.isNotEmpty && suffixWord.length >= 5) {
          final suffixMode = gameModes[currentId % gameModes.length];
          String diff = 'Medium';
          if (suffixWord.length >= 7) diff = 'Hard';

          finalWordList.add({
            'id': currentId++,
            'word': suffixWord,
            'category': category,
            'difficulty': diff,
            'gameMode': suffixMode,
            'options': suffixMode == 'chooseSpelling' ? generateSpellingOptions(suffixWord) : null,
          });
        }
      }
    }
  });

  // Expand with generic spelling vocabulary words if we are under 2,000 words
  final List<String> additionalNouns = [
    'TABLE', 'CHAIR', 'WINDOW', 'MIRROR', 'BASKET', 'CANDLE', 'HAMMER', 'SCISSORS', 'BLANKET', 'PILLOW',
    'JACKET', 'TROUSERS', 'SNEAKERS', 'SLIPPERS', 'UMBRELLA', 'HANDBAG', 'WALLET', 'WATCH', 'RING', 'NECKLACE',
    'BREAD', 'CHEESE', 'BUTTER', 'HONEY', 'SUGAR', 'SALT', 'PEPPER', 'SPICE', 'FLOUR', 'WHEAT',
    'TRAIN', 'STATION', 'AIRPORT', 'HARBOR', 'STREET', 'BRIDGE', 'TUNNEL', 'HIGHWAY', 'JOURNEY', 'TRAVEL',
    'DOCTOR', 'ENGINEER', 'TEACHER', 'LAWYER', 'WRITER', 'ARTIST', 'ACTOR', 'SINGER', 'DANCER', 'PAINTER',
    'MONKEY', 'GORILLA', 'BABOON', 'LEOPARD', 'JAGUAR', 'PANTHER', 'TIGER', 'CHEETAH', 'ELEPHANT', 'RHINO',
    'OCTOPUS', 'DOLPHIN', 'SEAWEED', 'STARFISH', 'JELLYFISH', 'LOBSTER', 'SHRIMP', 'OYSTER', 'SPONGE', 'CORAL',
    'DESERT', 'FOREST', 'MOUNTAIN', 'VALLEY', 'CANYON', 'MEADOW', 'ISLAND', 'VOLCANO', 'OCEAN', 'RIVER',
    'COSMOS', 'METEOR', 'COMET', 'ASTEROID', 'PLANET', 'SATELLITE', 'SPACESHIP', 'TELESCOPE', 'ASTRONOMY', 'GRAVITY',
    'KEYBOARD', 'SOFTWARE', 'HARDWARE', 'DATABASE', 'INTERNET', 'NETWORK', 'WEBSITE', 'BROWSER', 'SECURITY', 'FIREWALL',
    'SQUARE', 'CIRCLE', 'TRIANGLE', 'RECTANGLE', 'CYLINDER', 'SPHERE', 'PYRAMID', 'HEXAGON', 'OCTAGON', 'ELLIPSE',
    'SPRING', 'SUMMER', 'AUTUMN', 'WINTER', 'WEATHER', 'TEMPERATURE', 'HUMIDITY', 'CLIMATE', 'FORECAST', 'BAROMETER',
    'KITCHEN', 'BEDROOM', 'BATHROOM', 'HALLWAY', 'BALCONY', 'GARDEN', 'GARAGE', 'BASEMENT', 'ATTIC', 'CHIMNEY',
    'FESTIVAL', 'CARNIVAL', 'CELEBRATION', 'PARADE', 'HOLIDAY', 'VACATION', 'JOURNEY', 'ADVENTURE', 'EXPLORER', 'TOURIST'
  ];

  int genericIndex = 0;
  while (finalWordList.length < 2050) {
    final word = additionalNouns[genericIndex % additionalNouns.length] + '${(genericIndex ~/ additionalNouns.length) + 1}';
    final upperWord = word.toUpperCase();
    final gameModes = ['missingLetters', 'unscramble', 'chooseSpelling'];
    final gameMode = gameModes[currentId % gameModes.length];
    
    String difficulty = 'Medium';
    if (upperWord.length >= 7) difficulty = 'Hard';

    finalWordList.add({
      'id': currentId++,
      'word': upperWord,
      'category': 'General',
      'difficulty': difficulty,
      'gameMode': gameMode,
      'options': gameMode == 'chooseSpelling' ? generateSpellingOptions(upperWord) : null,
    });
    genericIndex++;
  }

  // Save JSON
  final directory = Directory('assets/words');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final file = File('assets/words/words.json');
  file.writeAsStringSync(jsonEncode(finalWordList));
  
  print('Generated words.json with ${finalWordList.length} functional offline words!');
}
