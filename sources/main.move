module ant::main {
    use std::vector;

    use sui::balance::{Self, Supply};
    use sui::coin;
    use sui::object::{Self, UID};
    use sui::object_table::{Self, ObjectTable};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const NOT_END_TIM: u64 = 9;

    struct Diamond has drop {}

    struct Grain has drop {}

    struct GameInfo has key, store {
        id: UID,
        max_level: u64,
        diamond: Supply<Diamond>,
        grain: Supply<Grain>,
        player: object_table::ObjectTable<address, Player>,
    }

    const CD: u64 = 5;

    struct Player has key, store {
        id: UID,
        queen: object_table::ObjectTable<u64, Queen>,
        soldier: ObjectTable<u64, Soldier>,
        worker: ObjectTable<u64, Worker>,
        loss_grain: u64,
        incr_id: u64,
    }

    struct Queen has key, store {
        id: UID,
        next_time: u64,
        level: u32,
        man_hour: u64,
        lucky: u8,
        diamond: u64,
    }

    struct Soldier has key, store {
        id: UID,
        level: u32,
        hp: u256,
        strength: u256,
        magic: u256,
        speed: u256,
        armor: u256,
    }

    struct Worker has key, store {
        id: UID,
        level: u32,
        status: u8,
        next_time: u64,
        man_hour: u64,
        grain: u64,
    }

    struct Foo has key {
        id: UID,
        next_time: u64,
        work_time: u64,
        status: u8,
        start_time: u64,
        end_time: u64,
    }

    fun init(ctx: &mut TxContext) {
        let g = GameInfo {
            id: object::new(ctx),
            max_level: 0,
            diamond: balance::create_supply<Diamond>(Diamond {}),
            grain: balance::create_supply<Grain>(Grain {}),
            player: object_table::new(ctx),
        };
        register(&mut g, ctx);
        transfer::share_object(g);
    }

    public fun init_for_test(ctx: &mut TxContext) {
        let g = GameInfo {
            id: object::new(ctx),
            max_level: 0,
            diamond: balance::create_supply<Diamond>(Diamond {}),
            grain: balance::create_supply<Grain>(Grain {}),
            player: object_table::new(ctx),
        };
        transfer::share_object(g);
    }

    public entry fun register(gi: &mut GameInfo, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        //todo epoch_timestamp
        // let now = tx_context::epoch_timestamp(ctx);
        let now = 0;

        let queen = Queen {
            id: object::new(ctx),
            next_time: now + 100,
            level: 1,
            diamond: 5,
            man_hour: 100,
            lucky: 5,
        };
        let queen_tab = object_table::new<u64, Queen>(ctx);
        object_table::add(&mut queen_tab, 0, queen);

        let worker = mint_worker(ctx);
        let worker_tab = object_table::new<u64, Worker>(ctx);
        object_table::add(&mut worker_tab, 1, worker);

        let player = Player {
            id: object::new(ctx),
            queen: queen_tab,
            worker: worker_tab,
            soldier: object_table::new<u64, Soldier>(ctx),
            loss_grain: 0,
            incr_id: 2,
        };
        object_table::add(&mut gi.player, sender, player);
    }

    fun mint_worker(ctx: &mut TxContext): Worker {
        //todo epoch_timestamp
        // let now = tx_context::epoch_timestamp(ctx);
        let now = 0;
        let worker = Worker {
            id: object::new(ctx),
            level: 1,
            man_hour: 100,
            next_time: now + 100,
            status: 1,
            grain: 100,
        };
        return worker
    }

    public entry fun queen_harvest(
        gi: &mut GameInfo,
        queens: vector<u64>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        //todo epoch_timestamp
        // let now = tx_context::epoch_timestamp(ctx);
        let now = 0;
        let player = object_table::borrow_mut(&mut gi.player, sender);
        let len = vector::length(&mut queens);
        let i = 0;
        let total_bal = balance::zero<Diamond>();
        while (i < len) {
            let addr = vector::borrow_mut(&mut queens, i);
            let q = object_table::borrow_mut(&mut player.queen, *addr);
            if (now >= q.next_time) {
                let bal = balance::increase_supply(&mut gi.diamond, 100);
                balance::join(&mut total_bal, bal);
                // balance::join()
                q.next_time = 0;
            }
        };
        let c = coin::from_balance(total_bal, ctx);
        // transfer::transfer(c, sender);
        transfer::public_transfer(c, sender)
    }

    public entry fun worker_harvest(
        gi: &mut GameInfo,
        workers: vector<u64>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        //todo epoch_timestamp
        // let now = tx_context::epoch_timestamp(ctx);
        let now = 0;
        let player = object_table::borrow_mut(&mut gi.player, sender);
        let len = vector::length(&mut workers);
        let i = 0;
        let total_bal = balance::zero<Grain>();
        while (i < len) {
            let idx = vector::borrow(&mut workers, i);
            let w = object_table::borrow_mut(&mut player.worker, *idx);
            if (now >= w.next_time) {
                let bal = balance::increase_supply(&mut gi.grain, 1000);
                balance::join(&mut total_bal, bal);
                w.next_time = now + w.man_hour;
            }
        };
        let c = coin::from_balance(total_bal, ctx);
        transfer::public_transfer(c, sender);
    }

    public fun incr_id(player: &mut Player): u64 {
        player.incr_id = player.incr_id + 1;
        player.incr_id
    }

    /// view function

    public fun player_exist(gi: &mut GameInfo, addr: address): bool {
        let exist = object_table::contains(&mut gi.player, addr);
        exist
    }

    // public fun view_player(
    //     gi: &mut GameInfo,
    //     addr: address,
    // ): (&table::Table<u64, Queen>, &table::Table<u64, Worker>, &table::Table<u64, Soldier>) {
    //     let player = table::borrow(&mut gi.player, addr);
    //     (&player.queen, &player.worker, &player.soldier)
    // }
}