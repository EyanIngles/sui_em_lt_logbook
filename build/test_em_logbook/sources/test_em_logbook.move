
/// Module: test_em_logbook
module test_em_logbook::test_em_logbook {
    use std::string::String;
    //use test_em_logbook::utils;
    use sui::table; 


    const UNABLE_TO_FIND_EM_ID:u64 = 1; // error finding item_id

     // Define the Storage struct
    public struct Storage has key, store {
        id: UID,
        object_info: table::Table<u64, EM_light_item>, 
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
        };

        // transfer to the publisher:: not sure if this should be publicly shared or not.

        // why it should be publicly shared:: it would make sense for anyone to add to this
        // this would make it so that a whole organisation could use the program, i suppose these then could be separated
        // using different package_ids;

        //let owner = tx_context::sender(ctx);
        transfer::share_object(storage);
    }

    /// create a EM light item and make it a shared object.
    public entry fun create_new_em_item(school: String, location: String, em_id: String, test_time_in_minutes: u64, test_pass: bool, storage: &mut Storage, ctx: &mut TxContext) {
        let new_id = object::new(ctx);
        let signer = tx_context::sender(ctx);
        let epoch = tx_context::epoch(ctx);

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

            /// this function now does not work... because the EM_light_item is now owned by on object.
            /// we will use the ID to fecth the UID and change it that way.
        public entry fun update_em_item_via_location_and_emid(storage: &mut Storage, location: String, em_id: String, test_time_in_minutes: u64, test_pass: bool,  ctx: &mut TxContext) {
        let signer = tx_context::sender(ctx);
        let epoch = tx_context::epoch(ctx);
        
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

         // gets the current length of the table so we can assign the next number on the length.
    public fun get_table_length(storage: &Storage):u64 {
        table::length(&storage.object_info)
    }
    /// used for adding to a table. 
    public fun add_em_item_to_list(storage: &mut Storage, index: u64, object_id: EM_light_item) { // may need this to ensure it is the owner.( the ctx)
        table::add(&mut storage.object_info, index, object_id)
    }
    /// gets the UID of the indexed item in the table.
    public fun get_uid_of_item(storage: &Storage, index: u64):&EM_light_item {
        table::borrow(&storage.object_info, index)
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
        };
        let school = b"school".to_string();
        let location = b"location".to_string();
        let em_id = b"em_id3".to_string();
        let em_id1 = b"em_id56".to_string();
        let em_id2 = b"em_id123".to_string();


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
