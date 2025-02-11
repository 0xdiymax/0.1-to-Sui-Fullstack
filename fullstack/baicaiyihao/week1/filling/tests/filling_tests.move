#[test_only]
module filling::filling_tests;

use filling::filling::{Self, State, Profile};
use sui::test_scenario;
use std::string;
use sui::test_utils::assert_eq;

#[test]
fun test_create_profile() {
    let user = @0xa;
    let mut scenario_val = test_scenario::begin(user);
    let scenario = &mut scenario_val;

    filling::init_for_testing(test_scenario::ctx(scenario));
    test_scenario::next_tx(scenario, user);
    let name = string::utf8(b"Alice");
    let desc = string::utf8(b"sui mover");
    {
        let mut state = test_scenario::take_shared<State>(scenario);
        filling::create_profile(
            name,
            desc,
            &mut state,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(state);
    };
    let tx = test_scenario::next_tx(scenario, user);
    let expect_no_events = 1;
    assert_eq(
        test_scenario::num_user_events(&tx),
        expect_no_events
    );
    {
        let state = test_scenario::take_shared<State>(scenario);
        let profile = test_scenario::take_from_sender<Profile>(scenario);
        assert_eq(
            filling::check_if_has_profile(user, &state),
            option::some(object::id_to_address(object::borrow_id(&profile)))
        );
        test_scenario::return_shared(state);
        test_scenario::return_to_sender(scenario, profile);
    };
    test_scenario::end(scenario_val);
}