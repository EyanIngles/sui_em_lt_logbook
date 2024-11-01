import { configureStore } from '@reduxjs/toolkit'
import betting from './betting_store'

export const store = configureStore({
  reducer: {
    betting,
  },
  middleware: getDefaultMiddleware =>
    getDefaultMiddleware({
        serializableCheck: false
    })
})
