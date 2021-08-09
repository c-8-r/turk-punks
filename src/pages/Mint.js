

import { Button, Frame, Range, ProgressBar } from '@react95/core'
import { useState } from 'react'

import './Mint.sass'


const Page = () => {

    const mintPrice = 0.025;
    const [mintAmount, setMintAmount] = useState(1)

    const [totalSupply, setTotalSupply] = useState(15000)
    const [minted, setMinted] = useState(2354)


    return (

        <header className="header">
            <h1>TurkPunks Character Sale</h1>
            <h2>
                <span style={{ color: "#efefef" }}>0.025 ETH</span> Per Character
            </h2>
            <Frame className="frame">
                <div>
                    <h2>Amount: {mintAmount} {mintAmount === 1 ? "TurkPunk" : "TurkPunks"} </h2>
                    <h2>Total Price: ~{Number(mintAmount * mintPrice).toFixed(3)} ETH + Fee</h2>
                </div>
                <div className="rangeRow" >
                    <Range
                        className="rangeSlider"
                        min="1"
                        max={totalSupply - minted}
                        value={mintAmount}
                        onChange={(e) => setMintAmount(Number(e.target.value))}
                    />
                    <Button className="mintButton">
                        Mint Now
                    </Button>
                </div>
                <span>(Swipe to increase)</span>
                <hr style={{ margin: "30px 0" }} />
                <div className="leftTPs">
                    <ProgressBar width={"80%"} percent={Number(minted * 100 / totalSupply).toFixed(2)} />
                    <h1>{minted} of {totalSupply} minted</h1>
                </div>
            </Frame>
        </header>




    )
}

export default Page