#[test_only]
module ant::main_test {

    use std::debug;

    use ant::main::{init_for_test, register, GameInfo, view_player};
    use sui::table;
    use sui::test_scenario;

    // fun g_test() {
    //     let admin = @0x111;
    //     let user = @0x222;
    //     let scenario = test_scenario::begin(user);
    //     let scenario_val = &mut scenario;
    //     let ctx = test_scenario::ctx(scenario_val);
    //     init_for_test(ctx)
    //     // test_scenario::next_tx(scenario_val,user);
    //     // let gi = test_scenario::take_from_sender<GameInfo>(scenario_val);
    //     // debug::print(&mut gi);
    //     //
    //     // register(&mut gi, ctx);
    //     // test_scenario::return_to_sender(&scenario, gi);
    // }

    fun xx() {
        let owner = @0x1;
        // Create a ColorObject and transfer it to @owner.
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            init_for_test(ctx);
        };

        test_scenario::next_tx(scenario, @0x66);
        {
            let gi = test_scenario::take_from_sender<GameInfo>(scenario);
            let ctx = test_scenario::ctx(scenario);
            register(&mut gi, ctx);
            test_scenario::return_to_sender(scenario, gi);
        };

        test_scenario::next_tx(scenario, @0x66);
        {
            let gi = test_scenario::take_from_sender<GameInfo>(scenario);
            let ctx = test_scenario::ctx(scenario);
            register(&mut gi, ctx);
            // debug::print(&gi);
            test_scenario::return_to_sender(scenario, gi);
        };

        test_scenario::next_tx(scenario, @0x66);
        {
            let gi = test_scenario::take_from_sender<GameInfo>(scenario);

            // let ctx = test_scenario::ctx(scenario);
            // let player = table::borrow_mut(&mut gi.player,)
            let (q, w, s) = view_player(&mut gi, @0x66);
            let queen = table::borrow(q, 0);
            debug::print(&queen);

            test_scenario::return_to_sender(scenario, gi);
        };

        test_scenario::end(scenario_val);
    }
}
