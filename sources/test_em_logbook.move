/// Module: test_em_logbook
module test_em_logbook::test_em_logbook {
    use std::string::String;
    //use test_em_logbook::utils;
    use sui::table; 
    use sui::balance::{Self, Balance};
    use sui::sui::{SUI};
    use sui::coin::{Self, Coin};
    //use sui::clock::Clock; //Clock is not needed at the moment.

    // constants that are for the fee amounts;    REF:: 1000000000 mist == 1 sui tokens
    const BECOME_AN_ACTIVE_USER_FEE_AMOUNT:u64 = 2000000000; //2 sui tokens
    const ACTIVITY_FEE:u64 = 100000000; // 0.1 sui token

    const UNABLE_TO_FIND_EM_ID:u64 = 1; // error finding item_id
    const UNABLE_TO_FIND_SCHOOL:u64 = 2;
    const ALREADY_ACTIVE_USER:u64 = 3; // already an active user. 
    const SIGNER_NOT_AN_ACTIVE_USER:u64 = 4; // signer who is trying to change details is not an active user, user must sign up first. 
    const INSUFFICIENT_FUNDS_AVAILABLE:u64 = 5; // user does not have enough finds to run this command.

     // Define the Storage struct
    public struct Storage has key, store {
        id: UID,
        object_info: table::Table<u64, EM_light_item>, 
        active_users: table::Table<address, bool>, // calls their address and whether or not they are an active user meaning they can change the EM_light_items
    }

    public struct Pay_pool has key, store {
        id: UID,
        balance: Balance<SUI>,
        owner: address
    }

    public struct EM_light_item has key, store { // not UID because it is going to be copied to a data base styled server?
    // or should this be a shared::object and just use the person last used it to sign to show they are the ones who last signed it?
        id: UID, // UID so that we can make it a shared object.
        signature: address, // the person who has signed to prove it was them who checked it.
        school: String, // the name of the school. // this may turn into a table style with options.
        em_id: String, // perhaps should have an id number such as EM01, EM02 and use a map to see where they should be situated.
        location: String, // the location of where the EM is located.
        test_time_in_minutes: u64, // the time tested 90mins is regs
        test_pass: bool, // did the test pass or fail.
        date_and_time: u64, // use epoch values and convert them, this will be stamped on once the item has been created.
    }

    // Initialize the storage object
    fun init(ctx: &mut TxContext) {
        let init_id = object::new(ctx);
        let storage = Storage {
            id: init_id,  // Corrected UID creation
            object_info: table::new(ctx),  // Initialize the table
            active_users: table::new(ctx),
        };
        // transfered for shared object.
        transfer::share_object(storage);
        // create pay_pool struct.
        let pay_pool = Pay_pool { //TODO not really a pool but a direct transfer to the owner.
            id: object::new(ctx),
            balance: balance::zero(),
            owner: tx_context::sender(ctx)
        };
        transfer::share_object(pay_pool)
    }
    public fun become_an_active_user(storage: &mut Storage, ctx: &mut TxContext) {
        let mut _tableRef = &mut storage.active_users;
        let signer = tx_context::sender(ctx);
        let address_check = table::contains(_tableRef, signer);
        if(address_check == false) {
            
        table::add(_tableRef, signer, true)
        } else {
            abort(ALREADY_ACTIVE_USER)
        }
    }
//TODO: once this is ready to be used after testing, this pay_fee function should non-public and be called from other functions..
    public fun pay_fee(pay_pool: &Pay_pool, balance: &mut Coin<SUI>, fee_amount: u64, ctx: &mut TxContext) {
        // make it so user can pay fee here, then we will need to add this fee_pay to the become an active user with an larger amount and then 
        // add it to each other function but have it as a smaller fee.
        // fee for create active user should be something like 2 sui tokens
        // fee for other function usage should be something like 0.1 sui.
        // these fees will then go into the pool and only the owner can withdraw...
        let recipient = pay_pool.owner;

        let wallet_balance = coin::value(balance);
        if(wallet_balance < fee_amount) {
            abort(INSUFFICIENT_FUNDS_AVAILABLE)
        };
        let fee_transfer = coin::split(balance, fee_amount, ctx);
        transfer::public_transfer(fee_transfer, recipient);

    }

    /// create a EM light item and make it a shared object.
    public entry fun create_new_em_item(school: String, location: String, em_id: String, test_time_in_minutes: u64, test_pass: bool, storage: &mut Storage, ctx: &mut TxContext) {
        let new_id = object::new(ctx);
        let signer = tx_context::sender(ctx);
        let epoch = ctx.epoch_timestamp_ms(); //get the timestamp_ms for current block -- not as accurate as clock.
        let mut _tableRef = &storage.active_users;
        let address_check = table::contains(_tableRef, signer);
        if(address_check == false){
            abort(SIGNER_NOT_AN_ACTIVE_USER)
        };

        let new_light_item = EM_light_item {
            id: new_id, // UID so that we can make it a shared object.
            signature: signer, // the person who has signed to prove it was them who checked it.
            school, // the name of the school. // this may turn into a table style with options.
            em_id, // perhaps should have an id number such as EM01, EM02 and use a map to see where they should be situated.
            location, // the location of where the EM is located.
            test_time_in_minutes , // the time tested 90mins is regs
            test_pass, // did the test pass or fail.
            date_and_time: epoch, // use epoch values and convert them, this will be stamped on once the item has been created.
        };
        let next_index = get_table_length(storage) + 1;
        add_em_item_to_list(storage, next_index, new_light_item);
        // storage: &mut Storage, index: u64, object_id: UID, _ctx: &mut TxContext
            //TODO: got new_id to use for emitting an event to keep track of
        }
           
        public entry fun update_em_item_via_location_and_emid(storage: &mut Storage, location: String, em_id: String, test_time_in_minutes: u64, test_pass: bool,  ctx: &mut TxContext) {
        let signer = tx_context::sender(ctx);
        let epoch = ctx.epoch_timestamp_ms();
        let user_check = check_if_user_is_active(storage, signer);
        if(user_check == false) {
            abort(SIGNER_NOT_AN_ACTIVE_USER)
        };
        
        // reassigning the values to the new updated values.
        let table_index = get_index_via_em_id_and_location(storage, em_id, location);
        let table_ref = &mut storage.object_info;
        let object = table::borrow_mut(table_ref, table_index);

        // update the table.
        object.signature = signer;
        object.test_time_in_minutes = test_time_in_minutes;
        object.test_pass = test_pass;
        object.date_and_time = epoch;
        }

        /// Helpers used to call and check information. /// These helpers are now useless...
        public entry fun check_school(storage: &Storage, index: u64): String {
            let table_ref = &storage.object_info;
            let em_light = table::borrow(table_ref, index);
            em_light.school
        }
        public entry fun check_location(storage: &Storage, index: u64): String {
            let table_ref = &storage.object_info;
            let em_light = table::borrow(table_ref, index);
            em_light.location
        }
        public entry fun check_em_id(storage: &Storage, index: u64): String {
            let table_ref = &storage.object_info;
            let em_light = table::borrow(table_ref, index);
            em_light.em_id
        }
        public fun check_if_user_is_active(storage: &mut Storage, wallet_address: address): &bool {
            let table_ref = &storage.active_users;
            let active_user = table::borrow(table_ref, wallet_address);
            active_user
        }

        public fun get_index_via_em_id(storage: &mut Storage, em_id: String): u64 {
            let table_ref = &storage.object_info;
            let mut i = 1;
            let mut em_light = table::borrow(table_ref, i); // run at 0 and continue to go through table.
            let length = get_table_length(storage);
            let id_found = em_id; // this is what we are searching for...

            while(i <= length || em_light.em_id == id_found) {
                em_light = table::borrow(table_ref, i);
                if(em_light.em_id == em_id){
                    return i
                };
                i = i + 1
            };
                abort(UNABLE_TO_FIND_EM_ID) 
                // if it is found, it should return before getting to the abort section.
        }
        /// function to get an index via using em_id and location.
        public fun get_index_via_em_id_and_location(storage: &mut Storage, em_id: String, location: String): u64 {
            let table_ref = &storage.object_info;
            let mut i = 1;
            let mut em_light = table::borrow(table_ref, i); // run at 0 and continue to go through table.
            let length = get_table_length(storage);
            let id_found = em_id; // this is what we are searching for...

            while(i <= length || (em_light.em_id == id_found && em_light.location == location)) {
                em_light = table::borrow(table_ref, i);
                if(em_light.em_id == em_id){
                    return i
                };
                i = i + 1
            };
                abort(UNABLE_TO_FIND_EM_ID) 
                // if it is found, it should return before getting to the abort section.
        }

        /// function to get an index via using school.
        public fun get_index_via_school(storage: &mut Storage, school: String): u64 {
            let table_ref = &storage.object_info;
            let mut i = 1;
            let mut em_light = table::borrow(table_ref, i); // run at 0 and continue to go through table.
            let length = get_table_length(storage);
            let school_found = school; // this is what we are searching for...

            while(i <= length || (em_light.em_id == school_found)) {
                em_light = table::borrow(table_ref, i);
                if(em_light.school == school){
                    return i
                };
                i = i + 1
            };
                abort(UNABLE_TO_FIND_SCHOOL) 
                // if it is found, it should return before getting to the abort section.
        }

        public fun get_index_vector_via_school(storage: &mut Storage, school: String): vector<u64> {
            let table_ref = &storage.object_info;
            let school_string = school;
            let mut array:vector<u64> = vector::empty();
            let mut i = 1;
            let mut _em_light = table::borrow(table_ref, i); // run at 0 and continue to go through table.
            let length = get_table_length(storage);

            while(i <= length) {
                _em_light = table::borrow(table_ref, i);
                if(_em_light.school == school_string){
                    array.push_back(i)
                };
                i = i + 1
            };
            if (vector::is_empty(&array)) {
                abort(UNABLE_TO_FIND_SCHOOL)
            };
               return array
                // if it is found, it should return before getting to the abort section.
        }

         // gets the current length of the table so we can assign the next number on the length.
    public fun get_table_length(storage: &Storage):u64 {
        table::length(&storage.object_info)
    }
    /// used for adding to a table. 
    fun add_em_item_to_list(storage: &mut Storage, index: u64, object_id: EM_light_item) { // may need this to ensure it is the owner.( the ctx)
        table::add(&mut storage.object_info, index, object_id)
    }
    /// gets the object of the indexed item in the table.
    public fun get_object_of_em_item(storage: &Storage, index: u64):&EM_light_item {
        table::borrow(&storage.object_info, index)
    }























    /// Tests below here ///

    #[test_only]
    public fun INIT(ctx: &mut TxContext): Storage {
        let init_id = object::new(ctx);
        let storage = Storage {
            id: init_id,  // Corrected UID creation
            object_info: table::new(ctx),  // Initialize the table
            active_users: table::new(ctx)
        };
            storage
    }
    public fun create_em_items(storage: &mut Storage, runs: u64, school: String, ctx: &mut TxContext){
        let mut i = 0;
        let location = b"location1".to_string();
        let em_id = b"em_id".to_string();
        let test_time_in_minutes = 6;
        let test_pass = true;
        while(i < runs) {
            create_new_em_item(school,
             location,
              em_id,
               test_time_in_minutes,
                test_pass,
                 storage,
                  ctx);

                  i = i + 1;
        };
    }

    #[test]
    public fun test_become_active_user_and_only_call_once() {
       use sui::test_scenario;
    let signer = @0xCAFE;
        let not_active_user: u64 = 55;


    // First transaction executed by initial owner to create the sword
    let mut scenario = test_scenario::begin(signer);
    {
        let mut storage = INIT(scenario.ctx());
        become_an_active_user(&mut storage, scenario.ctx());

        let is_active = check_if_user_is_active(&mut storage, signer);
        assert!(is_active == true, not_active_user);
        transfer::share_object(storage);
    };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = ALREADY_ACTIVE_USER)]
    public fun test_EXPECT_FAIL_try_become_active_user_more_than_once () {
        use sui::test_scenario;
        let signer = @0xCAFE;
        let not_active_user: u64 = 55;


    // First transaction executed by initial owner to create the sword
    let mut scenario = test_scenario::begin(signer);
    {
        let mut storage = INIT(scenario.ctx());
        become_an_active_user(&mut storage, scenario.ctx());

        let is_active = check_if_user_is_active(&mut storage, signer);
        assert!(is_active == true, not_active_user);
        become_an_active_user(&mut storage, scenario.ctx());
        transfer::share_object(storage);
    };
        scenario.end();
    }


    #[test]
    public fun test_call_and_receive_multiple_indexs_via_school(){
        let mut ctx = tx_context::dummy();
        let mut storage = INIT(&mut ctx);
        let school = b"school".to_string();
        let school1 = b"hawthorn".to_string();
        let school2 = b"blob".to_string();
        let runs1 = 100;
        let runs2 = 25;
        let runs3 = 50;

        // becoming an active user;
        become_an_active_user(&mut storage, &mut ctx);

        create_em_items(&mut storage, runs1, school, &mut ctx);
        create_em_items(&mut storage, runs2, school1, &mut ctx);
        create_em_items(&mut storage, runs3, school2, &mut ctx);

        let table_length = get_table_length(&storage);
        assert!(table_length == 175, 10); // error, unable to find all expected in table array length.

        let array_school1 = get_index_vector_via_school(&mut storage, school);
        let array_school_length = vector::count!(&array_school1, |_e| true);
        assert!(array_school_length == runs1, 11); //unable to find school or expected a different number in vector.

        let array_school2 = get_index_vector_via_school(&mut storage, school1);
        let array_school_length1 = vector::count!(&array_school2, |_e| true);
        assert!(array_school_length1 == runs2, 11); //unable to find school or expected a different number in vector.

        let array_school3 = get_index_vector_via_school(&mut storage, school2);
        let array_school_length2 = vector::count!(&array_school3, |_e| true);
        assert!(array_school_length2 == runs3, 11); //unable to find school or expected a different number in vector.

        // transferring objects to get rid of the value attached to the function.
        transfer::share_object(storage);
    }

    #[test]
    public fun test_getting_index_via_em_id_call() {
    use sui::test_scenario;
    let initial_owner = @0xCAFE;

    // First transaction executed by initial owner to create the sword
    let mut scenario = test_scenario::begin(initial_owner);
    {
        let mut storage = Storage {
            id: object::new(scenario.ctx()),
            object_info: table::new(scenario.ctx()), 
            active_users: table::new(scenario.ctx())
        };
        let school = b"school".to_string();
        let location = b"location".to_string();
        let em_id = b"em_id3".to_string();
        let em_id1 = b"em_id56".to_string();
        let em_id2 = b"em_id123".to_string();

        // calling to become an active user.
        become_an_active_user(&mut storage, scenario.ctx());


        create_new_em_item(school,
        location, 
        em_id,
         90, 
         true,
         &mut storage, scenario.ctx());
         create_new_em_item(school,
        location, 
        em_id1,
         90, 
         true,
         &mut storage, scenario.ctx());
         create_new_em_item(school,
        location, 
        em_id2,
         90, 
         true,
         &mut storage, scenario.ctx());
         create_new_em_item(school,
        location, 
        em_id2,
         90, 
         true,
         &mut storage, scenario.ctx());

         let number = get_index_via_em_id(&mut storage, em_id1);
         assert!(number == 2, 69); // un able to find the em_id if error
         let number1 = get_index_via_em_id(&mut storage, em_id);
         assert!(number1 == 1, 70); // un able to find the em_id if error
         let number2 = get_index_via_em_id(&mut storage, em_id2);
         assert!(number2 == 3, 71); // un able to find the em_id if error

        transfer::share_object(storage)
    };
        scenario.end();
    }
}
