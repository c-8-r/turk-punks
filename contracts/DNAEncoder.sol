// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract DNAEncoder {

    uint16 dna;

    function encode(uint body, uint eye, uint mouth, uint hair, uint rarity) public {
        dna = uint16(body + (eye * 5) + (mouth * 5 * 14) + (hair * 5 * 14 * 14) + (rarity * 5 * 14 * 14 * 18));
    }
    
    struct DNA {
        uint body;
        uint eye;
        uint mouth;
        uint hair;
        uint rarity;
    }
    
    function get_dna() public view returns (uint16) {
        return dna;
    }

    function decode() public view returns (DNA memory){
        uint rarity = dna / (5 * 14 * 14 * 18);
        uint hair = (dna % (5 * 14 * 14 * 18)) / (5 * 14 * 14);
        uint mouth = (dna % (5 * 14 * 14)) / (5 * 14);
        uint eye = (dna % (5 * 14)) / 5;
        uint body = (dna % 5);
        return DNA(
            body,
            eye,
            mouth,
            hair,
            rarity
        );
    }
}