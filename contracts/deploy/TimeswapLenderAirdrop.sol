// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "../external/solady/ERC20.sol";

contract TimeswapLenderAirdrop {

    uint8 public constant lenderCount = 48;

    struct AirdropData {
        address lender;
        uint256 amount;
    }

    struct AirdropLocals {
        ERC20 token;
        uint256 totalAmount;
    }

    function executeAirdrop(
        address airdropToken,
        uint256 airdropAmount
    ) external {
        AirdropLocals memory locals;
        AirdropData[] memory data = new AirdropData[](lenderCount);
        data = getLenderData();

        for (uint256 i; i < data.length; ) {
            locals.totalAmount += data[i].amount;
            unchecked {
                ++i;
            }
        }

        locals.token = ERC20(airdropToken);

        for (uint256 i; i < data.length;) {
            // distribute pro-rata
            uint256 userAmount = airdropAmount 
                                    * data[i].amount 
                                    / locals.totalAmount;
            locals.token.transferFrom(msg.sender, data[i].lender, userAmount);
            unchecked {
                ++i;
            }
        }
    }

    function getLenderData() private pure returns (
        AirdropData[] memory data
    ) {
        data = new AirdropData[](lenderCount);

        data[0] = AirdropData(
            {
                lender: 0x000000e28fAA823d5B53ff6C2922c28335840375,
                amount: 3000.0e6
            }
        );


        data[1] = AirdropData(
            {
                lender: 0x0CB63719D7fbB807f82423ca42Cc3506a5AEDc10,
                amount: 431.0e6
            }
        );


        data[2] = AirdropData(
            {
                lender: 0x10b0000Bb4B7a07ab03f2d1da71A505B41F2BFB5,
                amount: 0.003855e6
            }
        );


        data[3] = AirdropData(
            {
                lender: 0x11B2f51DdeB69AE9E1Fb883Bfb2A4c9c67343a73,
                amount: 300.0e6
            }
        );


        data[4] = AirdropData(
            {
                lender: 0x1E48bceb74E3483ff6A3BBdb90C6AC8C11352A67,
                amount: 306.653052e6
            }
        );


        data[5] = AirdropData(
            {
                lender: 0x1c0A79ac5bD3315d7af05B5BEF2d0521dD86B53B,
                amount: 120.0e6
            }
        );


        data[6] = AirdropData(
            {
                lender: 0x225BBDf071c6800f1E5C8682088eC66f56D56A78,
                amount: 2177.05424e6
            }
        );


        data[7] = AirdropData(
            {
                lender: 0x2e84B79dd9773d712f9D20a98C4ee76541B9533D,
                amount: 1786.145562e6
            }
        );


        data[8] = AirdropData(
            {
                lender: 0x333101cc3C175Fb414989CD0477a0258Ee0E2cae,
                amount: 10000.0e6
            }
        );


        data[9] = AirdropData(
            {
                lender: 0x338e76D66eF221c46Ab95A703b52B270C747D200,
                amount: 6598.255384e6
            }
        );


        data[10] = AirdropData(
            {
                lender: 0x362379c21e2b23075E6B0e36a7ed3dE280C0b923,
                amount: 586.598153e6
            }
        );


        data[11] = AirdropData(
            {
                lender: 0x3890a0Cc0bDBBf7dd7904A199c87a788da85BE62,
                amount: 100.0e6
            }
        );


        data[12] = AirdropData(
            {
                lender: 0x3AE1352DD34Fe199212e1D4E946726299227F480,
                amount: 2797.0e6
            }
        );


        data[13] = AirdropData(
            {
                lender: 0x3E09D20Ea54b2D261b4E793d69a39f2c1Dcb6dd8,
                amount: 150.9e6
            }
        );


        data[14] = AirdropData(
            {
                lender: 0x407D6A41A7C2c18d735402F057A5D7469EC6c8d4,
                amount: 2310.296831e6
            }
        );


        data[15] = AirdropData(
            {
                lender: 0x41cB15f15C3438D465BC58B2A689b29fe68F1415,
                amount: 1000.0e6
            }
        );


        data[16] = AirdropData(
            {
                lender: 0x47E05bB20A14C9a27fa8706Af83Fff7a480de47F,
                amount: 2541.773593e6
            }
        );


        data[17] = AirdropData(
            {
                lender: 0x4ec744F218397F315EE4AB53A49D3D33019BfD05,
                amount: 3695.0e6
            }
        );


        data[18] = AirdropData(
            {
                lender: 0x505A46C88Ae9FAdc438934bB8Cc6AdC026d4B1Af,
                amount: 2000.0e6
            }
        );


        data[19] = AirdropData(
            {
                lender: 0x5697CE38fce437fb0510839047Cbe00174923Bb2,
                amount: 656.146193e6
            }
        );


        data[20] = AirdropData(
            {
                lender: 0x5F5AF1C426F5F24296E9bbB76d2D15531aa660E6,
                amount: 0.05e6
            }
        );


        data[21] = AirdropData(
            {
                lender: 0x602695c0A8AB763A4823a07E3f40AbF0D251b671,
                amount: 200.0e6
            }
        );


        data[22] = AirdropData(
            {
                lender: 0x62EE13473EB1F771C3788f70ea988499A6008881,
                amount: 499.932277e6
            }
        );


        data[23] = AirdropData(
            {
                lender: 0x635681E0B420198F03Cbcc4026eFa66Af3f5fb40,
                amount: 1000.0e6
            }
        );


        data[24] = AirdropData(
            {
                lender: 0x6586185c2b16E620db0Ab02e7Fca0c66DeE7C9Ea,
                amount: 5108.994426e6
            }
        );


        data[25] = AirdropData(
            {
                lender: 0x74e142df816C376bd35d7AE02914fC8168Fcd45f,
                amount: 708.737652e6
            }
        );


        data[26] = AirdropData(
            {
                lender: 0x7e34dDEf646E03E414e74fA8eC5d9D13e994AB8e,
                amount: 40.0e6
            }
        );


        data[27] = AirdropData(
            {
                lender: 0x893A83F5521001559883CB9682B15439C023E54f,
                amount: 2000.0e6
            }
        );


        data[28] = AirdropData(
            {
                lender: 0x8e2F7D5aAAE5ABbD5052aCb74019b9b11cb74349,
                amount: 2078.464586e6
            }
        );


        data[29] = AirdropData(
            {
                lender: 0x905DEAFB182b9F6B4d289822306C3CfdD6F40D54,
                amount: 2000.884055e6
            }
        );


        data[30] = AirdropData(
            {
                lender: 0x9214aF6d0d3075c92e3A98D67e910488b185ae5F,
                amount: 52.01e6
            }
        );


        data[31] = AirdropData(
            {
                lender: 0x972b0F9cDE1266e860E546ac92E783741769400F,
                amount: 2000.0e6
            }
        );


        data[32] = AirdropData(
            {
                lender: 0x9EAc3aCad64eE65122f267e58734A634f2062c3F,
                amount: 11.487133e6
            }
        );


        data[33] = AirdropData(
            {
                lender: 0x9c0D1F4a029c46265831D120DeE9CDc72F0aB3C3,
                amount: 8016.644236e6
            }
        );


        data[34] = AirdropData(
            {
                lender: 0xA0F4A4CD9312EA26Ee0CB6B3E9e92C3BfA33ad1A,
                amount: 7072.026062e6
            }
        );


        data[35] = AirdropData(
            {
                lender: 0xBe905f486a5AFC311EEF5cca184FaB073c3978fc,
                amount: 2999.2e6
            }
        );


        data[36] = AirdropData(
            {
                lender: 0xC2CA3C901c9EB1aB207fcDAc01a8c936AB48cDd4,
                amount: 701.827821e6
            }
        );


        data[37] = AirdropData(
            {
                lender: 0xCb06a3A0a30363229Fccdcc8401679C9AB542cD9,
                amount: 500.286773e6
            }
        );


        data[38] = AirdropData(
            {
                lender: 0xCcdeaBe485054a996E2Cc6A1706A4727CF21286B,
                amount: 13784.038598e6
            }
        );


        data[39] = AirdropData(
            {
                lender: 0xEd3Faf019BA00f4FA615eb3A4b0dD320c96323f7,
                amount: 5000.0e6
            }
        );


        data[40] = AirdropData(
            {
                lender: 0xEea019eD82A9fE1574C874Cf91b8323BE17b2Ce3,
                amount: 274.204256e6
            }
        );


        data[41] = AirdropData(
            {
                lender: 0xa15AAF9B9a85652CC7CD7fdA9f85e6404B806a50,
                amount: 13070.241974e6
            }
        );


        data[42] = AirdropData(
            {
                lender: 0xa3301C1654895fCC8853BD622D0A43e7789706f7,
                amount: 301.294118e6
            }
        );


        data[43] = AirdropData(
            {
                lender: 0xa8c2D5698334DcDCbBb04f25C5Bc8D8301A9A660,
                amount: 3587.360431e6
            }
        );


        data[44] = AirdropData(
            {
                lender: 0xaC88c8316c57253a16f482AEB0879020BE87DB25,
                amount: 11000.0e6
            }
        );


        data[45] = AirdropData(
            {
                lender: 0xc27e87cfe1fd2Ed6F43DFfFBb9E9e46428497a24,
                amount: 12045.0e6
            }
        );


        data[46] = AirdropData(
            {
                lender: 0xd6c54048e837b1924973F792aB01EBb7f6d45173,
                amount: 10.535352e6
            }
        );


        data[47] = AirdropData(
            {
                lender: 0xeB38dC66ef461fAe07F4cD2C49160aaBC584C82b,
                amount: 385.37e6
            }
        );
    }
}
