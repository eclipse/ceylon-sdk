
import ceylon.time.base {
    october,
    Month,
    february,
    sunday,
    april,
    august,
    january,
    march,
    june,
    saturday,
    september
}
import ceylon.time {
    Period,
    newTime = time,
    date,
    dateTime
}
import ceylon.test {
    assertTrue,
    test,
    assertFalse
}
import ceylon.time.timezone {
    timeZone
}
import ceylon.time.timezone.model {
	wallClockDefinition,
	AtTime,
	utcTimeDefinition,
	OnLastOfMonth,
	OnDay,
	OnFixedDay,
	OnFirstOfMonth,
	Rule
}

//Sample of more simple and correct tests:
//shared test void parseSimpleRuleLine() {
//	assertEquals(parseRule("Rule    Brazil    1931    only    -    Oct     3    11:00    1:00    S"),
//		Rule("Brazil", 1931, 1931, October, OnFixedDay(3), AtLocalTime(11, 00), Period{minutes=1}, "S"));
//}

//shared test void onFixedDayRuleProducesFixedDate() {
//	// This assumes my new designed proposed earlier
//	assert(OnFixedDate(3).date(1984, October) == Date(1984, October, 3));
//}

//"Last Sunday of February 2004 is February, 29th 2004"
//assert(OnLastOfMonth(Sunday).date(2004, February) == Date(2004, February, 29));
//
//"Last Sunday of February 2014 is February, 23th 2014"
//assert(OnLastOfMonth(Sunday).date(2014, February) == Date(2014, February, 23));
//
//"First Sunday on or after 15th of 2004 is February, 15. 2004"
//assert(OnFirstOfMonth(Saturday, 15).date(2004, February) == Date(2004, February, 15));
//
//"First Sunday on or after 15th of February 2012 is February, 19th 2012"
//assert(OnFirstOfMonth(Saturday, 15).date(2014, February) == Date(2012, February, 19));
//
//"First Sunday on or after 15th of February 2012 is February, 19th 2012"
//assert(OnFirstOfMonth(Saturday, 15).date(2014, February) == Date(2012, February, 19));
//
//"First Sunday on or after 28 of February is March, 4th 2012"
//assert(OnFirstOfMonth(Saturday, 28).date(2012, February) == Date(2012, March, 4));

List<Rule>? brazilRules = provider.rules.get("Brazil");
List<Rule>? falkRules = provider.rules.get("Falk");
List<Rule>? chileRules = provider.rules.get("Chile");

test void testBrazilRules() {
//Rule    Brazil    1931    only    -    Oct     3    11:00    1:00    S
    assertRule {
        _fromYear = 1931;
        _toYear = 1931;
        _month = october;
        _onDayRule = OnFixedDay(3);
        _atTimeRule = AtTime(newTime(11,0), wallClockDefinition);
        _period = Period{hours = 1;};
        _letter = "S";
        _rules = brazilRules;
    }; 
    
//Rule    Brazil    2013    2014    -    Feb    Sun>=15    0:00    0    -
    assertRule {
        _fromYear = 2013;
        _toYear = 2014;
        _month = february;
        _onDayRule = OnFirstOfMonth(sunday, 15);
        _atTimeRule = AtTime(newTime(0,0), wallClockDefinition);
        _period = Period();
        _letter = "-";
        _rules = brazilRules;
    }; 
    
}

test void testChileRules() {
//Rule    Chile    1987    only    -    Apr    12    3:00u    0    -
    assertRule {
        _fromYear = 1987;
        _toYear = 1987;
        _month = april;
        _onDayRule = OnFixedDay(12);
        _atTimeRule = AtTime(newTime(3,0), utcTimeDefinition);
        _period = Period();
        _letter = "-";
        _rules = chileRules;
    }; 
}

test void testFalkRules() {
//Rule    Falk    1984    1985    -    Apr    lastSun    0:00    0    -
    assertRule {
        _fromYear = 1984;
        _toYear = 1985;
        _month = april;
        _onDayRule = OnLastOfMonth(sunday);
        _atTimeRule = AtTime(newTime(0,0), wallClockDefinition);
        _period = Period();
        _letter = "-";
        _rules = falkRules;
    }; 
}

test void testRulesShouldMatch() {
//Rule    Falk    1983    only    -    Sep    lastSun    0:00    1:00    S
    value rule =
            Rule {
        fromYear = 1983;
        toYear = 1983;
        inMonth = september;
        onDay = OnLastOfMonth(sunday); //day 25
        atTime = AtTime(newTime(0,0), wallClockDefinition);
        save = Period{ hours = 1; };
        letter = "S";
    };
    
    value _1983_sep_1 = dateTime(1983, september, 1);
    value _1983_sep_25 = dateTime(1983, september, 25);
    value _1983_sep_26 = dateTime(1983, september, 26);
    //assertFalse( rule.matches(_1983_sep_1.instant(timeZone.utc)) );
    //assertTrue( rule.matches(_1983_sep_25.instant(timeZone.utc)) );
    //assertTrue( rule.matches(_1983_sep_26.instant(timeZone.utc)) );
}

test void testOnFixedDayRuleShouldMatch() {
    value sundayGreaterOrEqual31 = OnFixedDay(31);
    //assertFalse(sundayGreaterOrEqual31.matches(date(2014, june, 29)));
    //assertTrue(sundayGreaterOrEqual31.matches(date(2014, august, 31)));
    //
    //value saturdayGreaterOrEqual15 = OnFixedDay(1);
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 2)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 9)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 15)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 16)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 17)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 23)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 30)));
}

test void testOnFirstOfMonthRuleShouldMatch() {
    value sundayGreaterOrEqual31 = OnFirstOfMonth(sunday, 31);
    //assertTrue(sundayGreaterOrEqual31.matches(date(2014, august, 31)));
    //
    //value saturdayGreaterOrEqual15 = OnFirstOfMonth(saturday, 15);
    //assertFalse(saturdayGreaterOrEqual15.matches(date(2014, august, 2)));
    //assertFalse(saturdayGreaterOrEqual15.matches(date(2014, august, 9)));
    //assertFalse(saturdayGreaterOrEqual15.matches(date(2014, august, 15)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 16)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 17)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 23)));
    //assertTrue(saturdayGreaterOrEqual15.matches(date(2014, august, 30)));
}

test void testOnLastOfMonthRuleShouldMatch() {
    value result = OnLastOfMonth(sunday);
    //assertTrue(result.matches(date(2014, january, 26)));
    //assertTrue(result.matches(date(2014, march, 30)));
    //assertTrue(result.matches(date(2014, june, 29)));
    //assertTrue(result.matches(date(2014, august, 31)));
}

void assertRule(Integer _fromYear, Integer _toYear, Month _month, 
                OnDay _onDayRule,
                AtTime _atTimeRule,
                Period _period, String _letter, List<Rule>? _rules) {
    assert(exists _rules);

    value rule =
            Rule {
        fromYear = _fromYear;
        toYear = _toYear;
        inMonth = _month;
        onDay = _onDayRule;
        atTime = _atTimeRule;
        save = _period;
        letter = _letter;
    };
    
    assertTrue(_rules.contains(rule));
}