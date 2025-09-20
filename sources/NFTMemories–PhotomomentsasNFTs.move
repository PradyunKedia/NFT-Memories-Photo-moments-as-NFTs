module MyModule::NFTMemories {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::timestamp;

    /// Struct representing an NFT Memory (photo moment)
    struct Memory has store, key, copy, drop {
        id: u64,              // Unique identifier for the memory
        title: String,        // Title/description of the memory
        photo_hash: String,   // IPFS hash or URL of the photo
        created_at: u64,      // Timestamp when memory was created
        owner: address,       // Owner of the memory NFT
    }

    /// Struct to store all memories for a user
    struct MemoryCollection has store, key {
        memories: vector<Memory>,
        next_id: u64,
    }

    /// Function to initialize a memory collection for a user
    public fun initialize_collection(account: &signer) {
        let collection = MemoryCollection {
            memories: vector::empty<Memory>(),
            next_id: 1,
        };
        move_to(account, collection);
    }

    /// Function to create a new memory NFT
    public fun create_memory(
        account: &signer, 
        title: String, 
        photo_hash: String
    ) acquires MemoryCollection {
        let account_addr = signer::address_of(account);
        
        // Initialize collection if it doesn't exist
        if (!exists<MemoryCollection>(account_addr)) {
            initialize_collection(account);
        };

        let collection = borrow_global_mut<MemoryCollection>(account_addr);
        
        let memory = Memory {
            id: collection.next_id,
            title,
            photo_hash,
            created_at: timestamp::now_seconds(),
            owner: account_addr,
        };

        vector::push_back(&mut collection.memories, memory);
        collection.next_id = collection.next_id + 1;
    }
}