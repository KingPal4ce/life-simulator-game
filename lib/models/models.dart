class IdentityState {
  String occupation;
  String relationshipStatus;
  String criminalRecord;
  String fameLevel;
  String education;
  List<String> majorPastEvents;

  IdentityState({
    this.occupation = 'student',
    this.relationshipStatus = 'single',
    this.criminalRecord = 'none',
    this.fameLevel = 'unknown',
    this.education = 'no degree',
    this.majorPastEvents = const [],
  });

  Map<String, dynamic> toJson() => {
        'occupation': occupation,
        'relationshipStatus': relationshipStatus,
        'criminalRecord': criminalRecord,
        'fameLevel': fameLevel,
        'education': education,
        'majorPastEvents': majorPastEvents,
      };

  factory IdentityState.fromJson(Map<String, dynamic> json) => IdentityState(
        occupation: json['occupation'] as String? ?? 'student',
        relationshipStatus: json['relationshipStatus'] as String? ?? 'single',
        criminalRecord: json['criminalRecord'] as String? ?? 'none',
        fameLevel: json['fameLevel'] as String? ?? 'unknown',
        education: json['education'] as String? ?? 'no degree',
        majorPastEvents: (json['majorPastEvents'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}

class Decision {
  final int age;
  final String eventTitle;
  final String choiceText;
  final String outcome;

  Decision({
    required this.age,
    required this.eventTitle,
    required this.choiceText,
    required this.outcome,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'eventTitle': eventTitle,
        'choiceText': choiceText,
        'outcome': outcome,
      };

  factory Decision.fromJson(Map<String, dynamic> json) => Decision(
        age: json['age'] as int? ?? 0,
        eventTitle: json['eventTitle'] as String? ?? '',
        choiceText: json['choiceText'] as String? ?? '',
        outcome: json['outcome'] as String? ?? '',
      );

  @override
  String toString() => 'Age $age — "$eventTitle": chose "$choiceText" → $outcome';
}

class CallbackSeed {
  final int seedAge;
  final String seedDescription;
  final String emotionalTag;
  final String? involvedNPC;
  final List<String> possibleReturnTypes;
  final int callbackAgeMin;
  final int callbackAgeMax;

  CallbackSeed({
    required this.seedAge,
    required this.seedDescription,
    required this.emotionalTag,
    this.involvedNPC,
    required this.possibleReturnTypes,
    required this.callbackAgeMin,
    required this.callbackAgeMax,
  });

  Map<String, dynamic> toJson() => {
        'seedAge': seedAge,
        'seedDescription': seedDescription,
        'emotionalTag': emotionalTag,
        'involvedNPC': involvedNPC,
        'possibleReturnTypes': possibleReturnTypes,
        'callbackAgeMin': callbackAgeMin,
        'callbackAgeMax': callbackAgeMax,
      };

  factory CallbackSeed.fromJson(Map<String, dynamic> json) => CallbackSeed(
        seedAge: json['seedAge'] as int? ?? 0,
        seedDescription: json['seedDescription'] as String? ?? '',
        emotionalTag: json['emotionalTag'] as String? ?? '',
        involvedNPC: json['involvedNPC'] as String?,
        possibleReturnTypes: (json['possibleReturnTypes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        callbackAgeMin: json['callbackAgeMin'] as int? ?? 0,
        callbackAgeMax: json['callbackAgeMax'] as int? ?? 0,
      );
}

class PlayerStats {
  static const int schemaVersion = 4;

  int age;
  int happiness;
  int health;
  int smarts;
  int looks;
  int morality;
  int discipline;
  int popularity;
  int creativity;
  int wealth;
  int greed;
  int reputation;
  List<String> lifeLog;
  List<String> achievements;
  List<Decision> decisions;
  IdentityState identityState;
  List<String> npcSeeds;
  String? lifePath;
  List<String> unresolvedTensions;
  List<CallbackSeed> callbacks;

  PlayerStats({
    this.age = 0,
    this.happiness = 80,
    this.health = 90,
    this.smarts = 50,
    this.looks = 50,
    this.morality = 50,
    this.discipline = 50,
    this.popularity = 50,
    this.creativity = 50,
    this.wealth = 20,
    this.greed = 10,
    this.reputation = 50,
    this.lifeLog = const [],
    this.achievements = const [],
    this.decisions = const [],
    IdentityState? identityState,
    this.npcSeeds = const [],
    this.lifePath,
    this.unresolvedTensions = const [],
    this.callbacks = const [],
  }) : identityState = identityState ?? IdentityState();

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'age': age,
        'happiness': happiness,
        'health': health,
        'smarts': smarts,
        'looks': looks,
        'morality': morality,
        'discipline': discipline,
        'popularity': popularity,
        'creativity': creativity,
        'wealth': wealth,
        'greed': greed,
        'reputation': reputation,
        'lifeLog': lifeLog,
        'achievements': achievements,
        'decisions': decisions.map((d) => d.toJson()).toList(),
        'identityState': identityState.toJson(),
        'npcSeeds': npcSeeds,
        'lifePath': lifePath,
        'unresolvedTensions': unresolvedTensions,
        'callbacks': callbacks.map((c) => c.toJson()).toList(),
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] as int?;
    if (version == null || version < 1 || version > schemaVersion) {
      throw FormatException(
        'PlayerStats schema version mismatch: expected $schemaVersion, got $version',
      );
    }
    final isV1 = version == 1;
    final isPreV3 = version < 3;
    final isPreV4 = version < 4;
    return PlayerStats(
      age: json['age'] as int? ?? 0,
      happiness: json['happiness'] as int? ?? 80,
      health: json['health'] as int? ?? 90,
      smarts: json['smarts'] as int? ?? 50,
      looks: json['looks'] as int? ?? 50,
      morality: isV1 ? 50 : (json['morality'] as int? ?? 50),
      discipline: isV1 ? 50 : (json['discipline'] as int? ?? 50),
      popularity: isV1 ? 50 : (json['popularity'] as int? ?? 50),
      creativity: isV1 ? 50 : (json['creativity'] as int? ?? 50),
      wealth: isV1 ? 20 : (json['wealth'] as int? ?? 20),
      greed: isV1 ? 10 : (json['greed'] as int? ?? 10),
      reputation: isV1 ? 50 : (json['reputation'] as int? ?? 50),
      lifeLog: (json['lifeLog'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      achievements: (json['achievements'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      decisions: (json['decisions'] as List<dynamic>?)
              ?.map((e) => Decision.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      identityState: json['identityState'] != null
          ? IdentityState.fromJson(json['identityState'] as Map<String, dynamic>)
          : IdentityState(),
      npcSeeds: (json['npcSeeds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      lifePath: isPreV3 ? null : (json['lifePath'] as String?),
      unresolvedTensions: isPreV3
          ? []
          : (json['unresolvedTensions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      callbacks: isPreV4
          ? []
          : (json['callbacks'] as List<dynamic>?)
                  ?.map((e) => CallbackSeed.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
    );
  }
}

class EventOption {
  final String text;
  final String outcomeDescription;
  final int happinessEffect;
  final int healthEffect;
  final int smartsEffect;
  final int looksEffect;
  final int moralityEffect;
  final int disciplineEffect;
  final int popularityEffect;
  final int creativityEffect;
  final int wealthEffect;
  final int greedEffect;
  final int reputationEffect;
  final String? occupationUpdate;
  final String? relationshipUpdate;
  final String? criminalRecordUpdate;
  final String? fameLevelUpdate;
  final String? majorEventNote;
  final String? involvedNPC;
  final String? newTension;
  final bool? resolvesTension;

  EventOption({
    required this.text,
    this.outcomeDescription = '',
    this.happinessEffect = 0,
    this.healthEffect = 0,
    this.smartsEffect = 0,
    this.looksEffect = 0,
    this.moralityEffect = 0,
    this.disciplineEffect = 0,
    this.popularityEffect = 0,
    this.creativityEffect = 0,
    this.wealthEffect = 0,
    this.greedEffect = 0,
    this.reputationEffect = 0,
    this.occupationUpdate,
    this.relationshipUpdate,
    this.criminalRecordUpdate,
    this.fameLevelUpdate,
    this.majorEventNote,
    this.involvedNPC,
    this.newTension,
    this.resolvesTension,
  });

  factory EventOption.fromJson(Map<String, dynamic> json) {
    return EventOption(
      text: json['text'] as String? ?? '',
      outcomeDescription: json['outcome_description'] as String? ?? '',
      happinessEffect: json['happinessEffect'] as int? ?? 0,
      healthEffect: json['healthEffect'] as int? ?? 0,
      smartsEffect: json['smartsEffect'] as int? ?? 0,
      looksEffect: json['looksEffect'] as int? ?? 0,
      moralityEffect: json['moralityEffect'] as int? ?? 0,
      disciplineEffect: json['disciplineEffect'] as int? ?? 0,
      popularityEffect: json['popularityEffect'] as int? ?? 0,
      creativityEffect: json['creativityEffect'] as int? ?? 0,
      wealthEffect: json['wealthEffect'] as int? ?? 0,
      greedEffect: json['greedEffect'] as int? ?? 0,
      reputationEffect: json['reputationEffect'] as int? ?? 0,
      occupationUpdate: json['occupationUpdate'] as String?,
      relationshipUpdate: json['relationshipUpdate'] as String?,
      criminalRecordUpdate: json['criminalRecordUpdate'] as String?,
      fameLevelUpdate: json['fameLevelUpdate'] as String?,
      majorEventNote: json['majorEventNote'] as String?,
      involvedNPC: json['involvedNPC'] as String?,
      newTension: json['newTension'] as String?,
      resolvesTension: json['resolvesTension'] as bool?,
    );
  }
}

class GameEvent {
  final String title;
  final String description;
  final List<EventOption> options;

  GameEvent({
    required this.title,
    required this.description,
    required this.options,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      title: json['title'] as String,
      description: json['description'] as String,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => EventOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
