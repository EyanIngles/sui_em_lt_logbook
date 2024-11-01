import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import 'bootstrap/dist/css/bootstrap.min.css';

// react-redux store components
import { store } from './store/store'
import { Provider } from 'react-redux'

// mysten labs import for sui
import '@mysten/dapp-kit/dist/index.css';
import { createNetworkConfig, SuiClientProvider, WalletProvider } from '@mysten/dapp-kit';
import { getFullnodeUrl } from '@mysten/sui/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
// Config options for the networks you want to connect to
const { networkConfig } = createNetworkConfig({
	devnet: { url: getFullnodeUrl('devnet') },
	mainnet: { url: getFullnodeUrl('mainnet') },
});
const queryClient = new QueryClient();



const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
			<SuiClientProvider networks={networkConfig} defaultNetwork="devnet">
				<WalletProvider>
    <Provider store={store}>
    <App />
    </Provider>
    </WalletProvider>
			</SuiClientProvider>
		</QueryClientProvider>
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
