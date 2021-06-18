            START testP
            DECLARE I, Integer
            DECLARE E, Integer
            DECLARE F, Integer
            DECLARE A, Float
            DECLARE B, Float
            DECLARE C, Float
            DECLARE D, Float
            DECLARE LLL, Float_array, 100
            I_ADD F, E, T&1
            I_MUL 5, 5, T&2
            I_STORE T&1, I
lb&1:       F_UMINUS LLL[I], T&3
            F_MUL B, D, T&4
            F_ADD T&3, T&4, T&5
            F_SUB T&5, C, T&6
            F_STORE T&6, A
            INC I
            I_CMP I, T&2
            JL lb&1
            F_ADD A, 10, T&7
            F_DIV 10000.0, 87.0, T&8
            F_CMP T&7, T&8
            JL lb&2:
            F_ADD A, 3.14, T&9
            CALL print, T&9
            J lb&3:
lb&2        CALL print, 1.4, 2
lb&3        HALT testP
            DECLARE T&1, Integer
            DECLARE T&2, Integer
            DECLARE T&3, Float
            DECLARE T&4, Float
            DECLARE T&5, Float
            DECLARE T&6, Float
            DECLARE T&7, Float
            DECLARE T&8, Float
            DECLARE T&9, Float
