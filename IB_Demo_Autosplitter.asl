// Autosplitter for the Iron Bramble demo based off the Rusted Moss autosplitter

state("IronBramble") {
    int room: 0x2C46E78;
    int menu1: 0x2C5A648;
    int menu2: 0x2C5A64C;
}

startup {
    var settings_creator = new List<Tuple<int, int, string>> {
        Tuple.Create(282, 283, "Enter Rifle Room"),
        Tuple.Create(503, 502, "Enter Cinder Forest"),
        Tuple.Create(256, 258, "Enter Lark Arena")
    }; // Splits will go here in the future. Not used atm

    vars.used_transitions = new List<string>();

    foreach (var entry in settings_creator) {
        settings.Add(entry.Item1 + "-" + entry.Item2, false, entry.Item3);
    }
}

start {
    vars.used_transitions = new List<string>();
    return current.room == 279 && old.room == 203;
}


split {
    if (current.room != old.room) {
        print("Transition detected");
        var transition_string = old.room.ToString() + "-" + current.room.ToString();
        print(transition_string);
        if (settings[transition_string] && !vars.used_transitions.Contains(transition_string)) {
            vars.used_transitions.Add(transition_string);
            return true;
        }
    }

    // Check for ending split
    if (current.menu1 != 0 || current.menu2 != 0) {
        if (current.room == 258 && current.menu1 == 1 && current.menu2 == 1)
            return true;
    }

    return false;
}

reset {
    return current.room == 206 && old.room != 206;
}