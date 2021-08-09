import { ThemeProvider, GlobalStyle } from '@react95/core';
import '@react95/icons/icons.css';
import { Web3ReactProvider } from '@web3-react/core'
import Web3 from 'web3'
import CustomTaskbar from './components/CustomTaskbar';


import MintPage from './pages/Mint'


function getLibrary(provider) {
  return new Web3(provider);
}

const App = () => {


  return (
    <ThemeProvider>
      <GlobalStyle />
      <Web3ReactProvider getLibrary={getLibrary}>
        <MintPage />
        <CustomTaskbar />
      </Web3ReactProvider>
    </ThemeProvider>
  )
}

export default App
