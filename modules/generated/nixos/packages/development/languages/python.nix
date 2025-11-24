{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Python
    python3Packages.ueberzug

    uv

    (python3.withPackages (e: [
      e.matplotlib
      e.pygments
      e.numpy
      e.tkinter
      e.pandas
      e.jupyter
      e.plotly
      e.seaborn
      e.tqdm
      e.flask
      e.werkzeug
    ]))
  ];
}
