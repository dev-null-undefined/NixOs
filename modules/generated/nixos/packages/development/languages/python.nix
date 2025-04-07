{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Python
    python3Packages.ueberzug

    (python3.withPackages
      (e: [e.matplotlib e.pygments e.numpy e.tkinter e.pandas e.jupyter e.plotly e.seaborn e.tqdm]))
  ];
}
