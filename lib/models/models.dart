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

class PlayerStats {
  int age;
  int happiness;
  int health;
  int smarts;
  int looks;
  List<String> lifeLog;
  List<String> achievements;
  List<Decision> decisions;

  PlayerStats({
    this.age = 0,
    this.happiness = 80,
    this.health = 90,
    this.smarts = 50,
    this.looks = 50,
    this.lifeLog = const [],
    this.achievements = const [],
    this.decisions = const [],
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'happiness': happiness,
        'health': health,
        'smarts': smarts,
        'looks': looks,
        'lifeLog': lifeLog,
        'achievements': achievements,
        'decisions': decisions.map((d) => d.toJson()).toList(),
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      age: json['age'] as int? ?? 0,
      happiness: json['happiness'] as int? ?? 80,
      health: json['health'] as int? ?? 90,
      smarts: json['smarts'] as int? ?? 50,
      looks: json['looks'] as int? ?? 50,
      lifeLog: (json['lifeLog'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      achievements: (json['achievements'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      decisions: (json['decisions'] as List<dynamic>?)
              ?.map((e) => Decision.fromJson(e as Map<String, dynamic>))
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

  EventOption({
    required this.text,
    this.outcomeDescription = '',
    this.happinessEffect = 0,
    this.healthEffect = 0,
    this.smartsEffect = 0,
    this.looksEffect = 0,
  });

  factory EventOption.fromJson(Map<String, dynamic> json) {
    return EventOption(
      text: json['text'] as String? ?? '',
      outcomeDescription: json['outcome_description'] as String? ?? '',
      happinessEffect: json['happinessEffect'] as int? ?? 0,
      healthEffect: json['healthEffect'] as int? ?? 0,
      smartsEffect: json['smartsEffect'] as int? ?? 0,
      looksEffect: json['looksEffect'] as int? ?? 0,
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
      options: (json['options'] as List<dynamic>)
          .map((e) => EventOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
