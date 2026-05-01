import { create } from "zustand";

type UiState = {
  drawerOpen: boolean;
  loginDialogOpen: boolean;
  setDrawerOpen: (open: boolean) => void;
  openLoginDialog: () => void;
  closeLoginDialog: () => void;
};

export const useUiStore = create<UiState>((set) => ({
  drawerOpen: false,
  loginDialogOpen: false,
  setDrawerOpen: (drawerOpen) => set({ drawerOpen }),
  openLoginDialog: () => set({ loginDialogOpen: true }),
  closeLoginDialog: () => set({ loginDialogOpen: false }),
}));
