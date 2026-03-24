echo "#![cfg_attr(not(feature = \"std\"), no_std)]" > lib.rs
echo "use ink_lang as ink;" >> lib.rs
echo "" >> lib.rs
echo "#[ink::contract]" >> lib.rs
echo "mod real_estate {" >> lib.rs
echo "    #[ink(storage)]" >> lib.rs
echo "    pub struct RealEstate {" >> lib.rs
echo "        owner: AccountId," >> lib.rs
echo "        properties: u32," >> lib.rs
echo "    }" >> lib.rs
echo "" >> lib.rs
echo "    impl RealEstate {" >> lib.rs
echo "        #[ink(constructor)]" >> lib.rs
echo "        pub fn new() -> Self {" >> lib.rs
echo "            Self { owner: Self::env().caller(), properties: 0 }" >> lib.rs
echo "        }" >> lib.rs
echo "    }" >> lib.rs
echo "}" >> lib.rs