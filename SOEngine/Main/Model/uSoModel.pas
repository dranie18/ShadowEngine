unit uSoModel;

interface

uses
  System.SysUtils,
  uEngine2DClasses, uSoTypes, uCommonClasses, uSoEngineSize,
  uClasses, uSoObjectKeeper, uSoCollider, uSoFormattor, uSoObject,
  uSoAnimator, uSoKeyProcessor, uSoMouseProcessor, uSoLogicKeeper,
  uSoPropertyKeeper, uSoEngineOptions, uSoColliderExtenderFactory, uSoSoundKeeper,
  uSoEngineEvents;

type
  TSoModel = class
  private
    FCritical: TCriticalSection;
    FImage: TAnonImage;
    FOptions: TSoEngineOptions;
    // Workers
    FCollider: TSoCollider;
    FFormattor: TSoFormattor;
    FAnimator: TSoAnimator;
    // Keepers
    FObjectKeeper: TSoObjectKeeper;
    FLogicKeeper: TSoLogicKeeper;
    FSoundKeeper: TSoSoundKeeper;
    // Processors
    FKeyProcessor: TSoKeyProcessor;
    FMouseProcessor: TSoMouseProcessor;
    // Factories
    FColliderExtenderFactory: TSoColliderExtenderFactory;

    FEvents: TSoEngineEvents;
    FEngineSize: TSoEngineSize;
    procedure InitFactories;

    procedure SubscribeEvents;
  public
    // Workers
    property Collider: TSoCollider read FCollider;
    property Formattor: TSoFormattor read FFormattor;
    property Animator: TSoAnimator read FAnimator;
    // Keepers
    property ObjectKeeper: TSoObjectKeeper read FObjectKeeper;
    property SoundKeeper: TSoSoundKeeper read FSoundKeeper;
    property LogicKeeper: TSoLogicKeeper read FLogicKeeper;
//    property ContainerKeeper: TSoContainerKeeper read FContainerKeeper;
//    property LayoutKeeper: TSoLayoutKeeper read FLayoutKeeper;
    // Processors
    property KeyProcessor: TSoKeyProcessor read FKeyProcessor;
    property MouseProcessor: TSoMouseProcessor read FMouseProcessor;

    procedure ExecuteOnTick;
    procedure ExecuteKeyUp(ASender: TObject; Key: Word; KeyChar: Char; Shift: TShiftState); // Process key on tick
    procedure ExecuteKeyDown(ASender: TObject; Key: Word; KeyChar: Char; Shift: TShiftState); // Process key on tick
    procedure ExecuteMouseDown(ASender: TObject; AEventArgs: TMouseEventArgs);
    procedure ExecuteMouseUp(ASender: TObject; AEventArgs: TMouseEventArgs);
    procedure ExecuteMouseMove(Sender: TObject; AEventArgs: TMouseMoveEventArgs);
    constructor Create(
      const AEvents: TSoEngineEvents;
      const AImage: TAnonImage;
      const ACritical: TCriticalSection;
      const AOptions: TSoEngineOptions);
    destructor Destroy; override;
  end;

implementation

{ TSoModel }

constructor TSoModel.Create(
  const AEvents: TSoEngineEvents;
  const AImage: TAnonImage;
  const ACritical: TCriticalSection;
  const AOptions: TSoEngineOptions);
begin
  FCritical := ACritical;
  FEvents := AEvents;
  FOptions := AOptions;

  InitFactories;

  FObjectKeeper := TSoObjectKeeper.Create(FCritical);
  FLogicKeeper := TSoLogicKeeper.Create(FCritical);
  FCollider := TSoCollider.Create(FCritical, FColliderExtenderFactory.Produce, FOptions.ColliderOptions);
  FFormattor := TSoFormattor.Create(FCritical);
  FAnimator := TSoAnimator.Create(FCritical);
  FKeyProcessor := TSoKeyProcessor.Create(FCritical);
  FMouseProcessor := TSoMouseProcessor.Create(FCritical);
  FSoundKeeper := TSoSoundKeeper.Create(FCritical);

  SubscribeEvents;
end;

destructor TSoModel.Destroy;
begin
  FObjectKeeper.Free;
  FLogicKeeper.Free;
  FCollider.Free;
  FFormattor.Free;
  FAnimator.Free;
  FKeyProcessor.Free;
  FMouseProcessor.Free;

  inherited;
end;

procedure TSoModel.ExecuteKeyDown(ASender: TObject; Key: Word; KeyChar: Char; Shift: TShiftState);
begin
  FKeyProcessor.ExecuteKeyDown(Key, KeyChar, Shift);
end;

procedure TSoModel.ExecuteKeyUp(ASender: TObject; Key: Word; KeyChar: Char; Shift: TShiftState);
begin
  FKeyProcessor.ExecuteKeyUp(Key, KeyChar, Shift);
end;

procedure TSoModel.ExecuteMouseDown(ASender: TObject; AEventArgs: TMouseEventArgs);
begin
  FMouseProcessor.ExecuteMouseDown(AEventArgs);
end;

procedure TSoModel.ExecuteMouseMove(Sender: TObject; AEventArgs: TMouseMoveEventArgs);
begin
  FMouseProcessor.ExecuteMouseMove(AEventArgs);
end;

procedure TSoModel.ExecuteMouseUp(ASender: TObject; AEventArgs: TMouseEventArgs);
begin
  FMouseProcessor.ExecuteMouseUp(AEventArgs);
end;

procedure TSoModel.ExecuteOnTick;
begin
  FAnimator.Execute;
  FLogicKeeper.Execute;
  FCollider.Execute;
end;

procedure TSoModel.InitFactories;
begin
  FColliderExtenderFactory := TSoColliderExtenderFactory.Create(FOptions.ColliderOptions);
end;

procedure TSoModel.SubscribeEvents;
begin
  with FEvents do begin
    OnMouseDown.Add(ExecuteMouseDown);
    OnMouseUp.Add(ExecuteMouseUp);
    OnMouseMove.Add(ExecuteMouseMove);
  end;
end;

end.

