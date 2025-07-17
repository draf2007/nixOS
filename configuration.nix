{ config, pkgs, ... }:

{
  # ----- 1. Базовая система -----
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/sda";  # Для VMware (MBR)
    };
    # Ускоряем загрузку в VM
    initrd.verbose = false;
    consoleLogLevel = 0;
  };

  # ----- 2. Интеграция с VMware -----
  virtualisation.vmware.guest = {
    enable = true;
    headless = false;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "vmware" ];  # Драйвер для виртуальной графики
    displayManager.sddm.enable = true;
    desktopManager = {
      xterm.enable = false;
      plasma5.enable = false;     # Отключаем KDE (не нужно)
    };
  };

  # ----- 3. Hyprland -----
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ----- 4. Пользователь -----
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    initialPassword = "nixos";    # Пароль для входа
  };

  # ----- 5. Основные пакеты -----
  environment.systemPackages = with pkgs; [
    # Системные утилиты
    git
    vim
    wget
    curl
    htop

    # Hyprland-окружение
    waybar
    rofi-wayland
    foot               # Терминал
    grim               # Скриншоты
    slurp              # Выбор области
    wl-clipboard       # Буфер обмена
    mako               # Уведомления

    # Дополнительно
    firefox
  ];

  # ----- 6. Сеть -----
  networking = {
    hostName = "nixos-vm";
    networkmanager.enable = true;
    firewall.enable = false;     # Для удобства в VM
  };

  # ----- 7. Сервисы -----
  services = {
    openssh.enable = true;       # SSH-доступ
    pipewire = {                 # Звук
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    # Интеграция с VMware
    vmwareGuest.enable = true;
  };

  # ----- 8. Переменные окружения -----
  environment.variables = {
    NIXOS_OZONE_WL = "1";       # Для Wayland-приложений
    QT_QPA_PLATFORM = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";  # Фикс курсора в VM
  };

  # ----- 9. Автозапуск Hyprland -----
  systemd.services.hyprland-autostart = {
    description = "Autostart Hyprland";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprland}/bin/Hyprland";
      User = "nixos";
      PAMName = "login";
      WorkingDirectory = "/home/nixos";
    };
  };

  # ----- 10. Системные настройки -----
  system = {
    stateVersion = "23.11";
    autoUpgrade.enable = false;  # Отключаем в VM
  };
}